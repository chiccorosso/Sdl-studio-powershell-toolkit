add-type -path 'C:\Program Files\SDL\SDL Trados Studio\Studio2\Sdl.ProjectAutomation.FileBased.dll';
add-type -path 'C:\Program Files\SDL\SDL Trados Studio\Studio2\Sdl.ProjectAutomation.Core.dll';

function Get-TaskFileInfoFiles
{
	param([Sdl.Core.Globalization.Language] $language, [Sdl.ProjectAutomation.FileBased.FileBasedProject] $project)
	[Sdl.ProjectAutomation.Core.TaskFileInfo[]]$taskFilesList = @();
	foreach($taskfile in $project.GetTargetLanguageFiles($language))
	{
		$fileInfo = New-Object Sdl.ProjectAutomation.Core.TaskFileInfo;
		$fileInfo.ProjectFileId = $taskfile.Id;
		$fileInfo.ReadOnly = $false;
		$taskFilesList = $taskFilesList + $fileInfo;
	}
	return $taskFilesList;
}

function Remove-Project
{
	param ([Sdl.ProjectAutomation.FileBased.FileBasedProject] $projectToDelete)
	$projectToDelete.Delete();
}

function Validate-Task
{
	param ([Sdl.ProjectAutomation.Core.AutomaticTask] $taskToValidate)

	if($taskToValidate.Status -eq [Sdl.ProjectAutomation.Core.TaskStatus]::Failed)
	{
		Write-Host "Task "$taskToValidate.Name"was not completed.";  
		foreach($message in $taskToValidate.Messages)
		{
			Write-Host $message.Message -ForegroundColor red ;
		}
	}
	if($taskToValidate.Status -eq [Sdl.ProjectAutomation.Core.TaskStatus]::Invalid)
	{
		Write-Host "Task "$taskToValidate.Name"was not completed.";  
		foreach($message in $taskToValidate.Messages)
		{
			Write-Host $message.Message -ForegroundColor red ;
		}
	}
	if($taskToValidate.Status -eq [Sdl.ProjectAutomation.Core.TaskStatus]::Rejected)
	{
		Write-Host "Task "$taskToValidate.Name"was not completed.";  
		foreach($message in $taskToValidate.Messages)
		{
			Write-Host $message.Message -ForegroundColor red ;
		}
	}
	if($taskToValidate.Status -eq [Sdl.ProjectAutomation.Core.TaskStatus]::Cancelled)
	{
		Write-Host "Task "$taskToValidate.Name"was not completed.";  
		foreach($message in $taskToValidate.Messages)
		{
			Write-Host $message.Message -ForegroundColor red ;
		}
	}
	if($taskToValidate.Status -eq [Sdl.ProjectAutomation.Core.TaskStatus]::Completed)
	{
		Write-Host "Task "$taskToValidate.Name"was completed." -ForegroundColor green;  
	}
}

<#
	.DESCRIPTION
	Creates a new file based project. TM's are automatically assigned to the target languages.
	Following tasks are run automatically:
	- scan
	- convert to translatable format
	- copy to target languages
	- pretranslate
	- analyze
#>
function New-Project
{
	param([String] $projectName, [String] $projectDestination,
		[Sdl.Core.Globalization.Language] $sourceLanguage, 
		[Sdl.Core.Globalization.Language[]] $targetLanguages,
		[String[]] $pathToTMs, [String] $sourceFilesFolder)
	
	#create project info
	$projectInfo = new-object Sdl.ProjectAutomation.Core.ProjectInfo;
	$projectInfo.Name = $projectName;
	$projectInfo.LocalProjectFolder = $projectDestination;
	$projectInfo.SourceLanguage = $sourceLanguage;
	$projectInfo.TargetLanguages = $targetLanguages;
	
	#create file based project
	$fileBasedProject = New-Object Sdl.ProjectAutomation.FileBased.FileBasedProject $projectInfo
	$projectFiles = $fileBasedProject.AddFolderWithFiles($sourceFilesFolder, $false);

	#Assign TM's to project languages
	foreach($tmPath in $pathToTMs)
	{
		$tmTargetLanguageCulture = Get-TargetTMLanguage $tmPath;
		$tmTargetLanguage = Get-Language $tmTargetLanguageCulture.Name;
		[Sdl.ProjectAutomation.Core.TranslationProviderConfiguration] $tmConfig = $fileBasedProject.GetTranslationProviderConfiguration($tmTargetLanguage);
		$entry = New-Object Sdl.ProjectAutomation.Core.TranslationProviderCascadeEntry ($tmPath, $true, $true, $true);
		$tmConfig.Entries.Add($entry);
		$fileBasedProject.UpdateTranslationProviderConfiguration($tmTargetLanguage, $tmConfig);	
	}

	#Get source language project files IDs
	[Sdl.ProjectAutomation.Core.ProjectFile[]] $projectFiles = $fileBasedProject.GetSourceLanguageFiles();
	[System.Guid[]] $sourceFilesGuids = Get-Guids $projectFiles;

	#run preparation tasks
	Validate-Task $fileBasedProject.RunAutomaticTask($sourceFilesGuids,[Sdl.ProjectAutomation.Core.AutomaticTaskTemplateIds]::Scan);
	Validate-Task $fileBasedProject.RunAutomaticTask($sourceFilesGuids,[Sdl.ProjectAutomation.Core.AutomaticTaskTemplateIds]::ConvertToTranslatableFormat);
	Validate-Task $fileBasedProject.RunAutomaticTask($sourceFilesGuids,[Sdl.ProjectAutomation.Core.AutomaticTaskTemplateIds]::CopyToTargetLanguages);

	
	#run pretranslate and analyze
	foreach($targetLanguage in $targetLanguages)
	{
		#Get target language project files IDs
		$targetFiles = $fileBasedProject.GetTargetLanguageFiles($targetLanguage);
		[System.Guid[]] $targetFilesGuids = Get-Guids $targetFiles;
		
		Validate-Task $fileBasedProject.RunAutomaticTask($targetFilesGuids,[Sdl.ProjectAutomation.Core.AutomaticTaskTemplateIds]::PreTranslateFiles);
		Validate-Task $fileBasedProject.RunAutomaticTask($targetFilesGuids,[Sdl.ProjectAutomation.Core.AutomaticTaskTemplateIds]::AnalyzeFiles);
	}

	#save whole project
	$fileBasedProject.Save(); 
}

<#
	.DESCRIPTION
	Opens project on specified path.
#>
function Get-Project
{
	param([String] $projectFilePath)
	#open file based project
	$fileBasedProject = New-Object Sdl.ProjectAutomation.FileBased.FileBasedProject($projectFilePath);
	return $fileBasedProject;
}


function Get-AnalyzeStatistics
{
	param([Sdl.ProjectAutomation.FileBased.FileBasedProject] $project)
	
	$projectStatistics = $project.GetProjectStatistics();
	
	$targetLanguagesStatistics = $projectStatistics.TargetLanguageStatistics;
	
	foreach($targetLanguageStatistic in  $targetLanguagesStatistics)
	{
		Write-Host ("Exact Matches (characters): " + $targetLanguageStatistic.AnalysisStatistics.Exact.Characters);
		Write-Host ("Exact Matches (words): " + $targetLanguageStatistic.AnalysisStatistics.Exact.Words);
		Write-Host ("New Matches (characters): " + $targetLanguageStatistic.AnalysisStatistics.New.Characters);
		Write-Host ("New Matches (words): " + $targetLanguageStatistic.AnalysisStatistics.New.Words);
		Write-Host ("New Matches (segments): " + $targetLanguageStatistic.AnalysisStatistics.New.Segments);
		Write-Host ("New Matches (placeables): " + $targetLanguageStatistic.AnalysisStatistics.New.Placeables);
		Write-Host ("New Matches (tags): " + $targetLanguageStatistic.AnalysisStatistics.New.Tags);
	}
}

Export-ModuleMember Remove-Project;
Export-ModuleMember New-Project;
Export-ModuleMember Get-Project;
Export-ModuleMember Get-AnalyzeStatistics;
Export-ModuleMember Get-TaskFileInfoFiles;