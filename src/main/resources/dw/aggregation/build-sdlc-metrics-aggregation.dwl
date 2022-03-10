%dw 2.0
output application/json
var bitbucketData = payload[0].payload default []
var confluenceData = payload[1].payload default []
var jenkinsData = payload[2].payload default []
var jiraData = payload[3].payload default []
var splunkData = payload[4].payload default []
var azureDevOpsBoardsData = payload[5]
var azureDevOpsReposData = payload[6].payload default []
var azureDevOpsPipelinesData = payload[7].payload default []

var bitBucketMetrics = {totalRepositories: bitbucketData.size default 0}

var confluenceMetrics = {
			totalPages: confluenceData.size default 0,
			totalPagesCreatedInLast30Days : sizeOf(confluenceData.results filter ($.history.createdDate as String {format: "yyyy-MM-dd'T'HH:mm:ss.SSS"} as Date) > now() - |P30D|) default 0,
			totalPagesUpdatedInLast30Days : sizeOf(confluenceData.results filter ($.history.lastUpdated.when as String {format: "yyyy-MM-dd'T'HH:mm:ss.SSS"} as Date) > now() - |P30D|) default 0,
			topContributorsInLast30Days : ((confluenceData.results filter ($.history.lastUpdated.when as String {format: "yyyy-MM-dd'T'HH:mm:ss.SSS"} as Date) >now() - |P30D| and $.history.lastUpdated.by.publicName != null
    groupBy $.history.lastUpdated.by.publicName) mapObject {
        ($$): sizeOf($)
    } orderBy(-$)) default null
		}
var jenkinsMetrics = {
			totalJobs : sizeOf(jenkinsData.jobs)  default 0,
			totalSuccessfulJobs : sizeOf(jenkinsData.jobs filter $.color == "blue")  default 0,     
            totalFailedJobs : sizeOf(jenkinsData.jobs filter $.color == "red") default 0,
			totalUnexecutedJobs : sizeOf(jenkinsData.jobs filter $.color == null)  default 0
		}

var jiraMetrics = {
			workItemsInBacklog: jiraData[1].payload.total default null,
    		workItemsInSprint : jiraData[0].payload.total,
    		workItemsInSprintByType : (jiraData[0].payload.issues groupBy $.fields.issuetype.name) mapObject  {($$) : sizeOf($)} default null,
    		workItemsInSprintByStatus : (jiraData[0].payload.issues groupBy $.fields.status.name) mapObject  {($$) : sizeOf($)} default null
		}

var azuredevopsBoardsMetrics = { 
			workItemsInBacklog: sizeOf(azureDevOpsBoardsData.payload[0].payload) default 0,
    		workItemsInSprint : sizeOf(azureDevOpsBoardsData.payload[1].payload) default 0,
    		workItemsInSprintByType : (azureDevOpsBoardsData.payload[1].payload groupBy $.taskType ) mapObject  {($$) : sizeOf($)} default null, 	//may not be able to normalise types 
    		workItemsInSprintByStatus : (azureDevOpsBoardsData.payload[1].payload groupBy $.status) mapObject  {($$) : sizeOf($)} default null //may not be able to normalise status - may not want to? 
    	}

var azureDevopsReposMetrics = {
    		totalRepositories: azureDevOpsReposData.size
    	}

var azureDevopsPipelinesMetrics = {
    totalJobs: sizeOf(azureDevOpsPipelinesData) default 0,
    totalSuccessfulJobs: sizeOf(azureDevOpsPipelinesData filter() -> $.result == "succeeded") default 0,
    totalFailedJobs: sizeOf(azureDevOpsPipelinesData filter() -> $.result == "failed") default 0,
    totalUnexecutedJobs: sizeOf(azureDevOpsPipelinesData filter() -> $.result == "no runs") default 0
}

fun sumMetrics(metrics) = 
    sum(metrics filter(typeOf($) == Number)) default 0

---
{
	date: vars.date,
	sdlcMetrics: {
        //summary view with normalised field names - values being a sum of various system specifics
		documentation: {
			totalPages: confluenceMetrics.totalPages default 0, //+ any other data source
			pagesCreatedInLast30Days: confluenceMetrics.totalPagesCreatedInLast30Days default 0,
			pagesUpdatedInLast30Days: confluenceMetrics.totalPagesUpdatedInLast30Days default 0,
			topContributorsInLast30Days: confluenceMetrics.topContributorsInLast30Days default {}
		},
		codeRepositories: {
			totalRepositories: sumMetrics([bitBucketMetrics.totalRepositories, azureDevopsReposMetrics.totalRepositories])
		},
		buildJobs: {
			totalJobs: sumMetrics([jenkinsMetrics.totalJobs,azureDevopsPipelinesMetrics.totalJobs]),
			totalSuccessfulJobs: sumMetrics([jenkinsMetrics.totalSuccessfulJobs, azureDevopsPipelinesMetrics.totalSuccessfulJobs]),
			totalFailedJobs: sumMetrics([jenkinsMetrics.totalFailedJobs, azureDevopsPipelinesMetrics.totalFailedJobs]),
			totalUnexecutedJobs: sumMetrics([jenkinsMetrics.totalUnexecutedJobs, azureDevopsPipelinesMetrics.totalUnexecutedJobs]) 
		},
		
		workItems: {
			workItemsInBacklog: sumMetrics(
                [jiraMetrics.workItemsInBacklog, 
                azuredevopsBoardsMetrics.workItemsInBacklog]),
			workItemsInSprint: sumMetrics([jiraMetrics.workItemsInSprint,
                azuredevopsBoardsMetrics.workItemsInSprint]), 
			workItemsInSprintByType: { 
                Task: sumMetrics([jiraMetrics.workItemsInSprintByType.Task, azuredevopsBoardsMetrics.workItemsInSprintByType.Task]),
                Bug: sumMetrics([jiraMetrics.workItemsInSprintByType.Bug, azuredevopsBoardsMetrics.workItemsInSprintByType.Bug]),
                Epic: sumMetrics([jiraMetrics.workItemsInSprintByType.Epic, azuredevopsBoardsMetrics.workItemsInSprintByType.Epic]),
                Issue: sumMetrics([jiraMetrics.workItemsInSprintByType.Issue, azuredevopsBoardsMetrics.workItemsInSprintByType.Issue]),
                Story: sumMetrics([jiraMetrics.workItemsInSprintByType.Story, azuredevopsBoardsMetrics.workItemsInSprintByType.Story])
            },	
			workItemsInSprintByStatus: {
                "In Progress": sumMetrics([jiraMetrics.workItemsInSprintByStatus."In Progress", azuredevopsBoardsMetrics.workItemsInSprintByStatus."Doing"]),
                "To Do": sumMetrics([jiraMetrics.workItemsInSprintByStatus."To Do", azuredevopsBoardsMetrics.workItemsInSprintByStatus."To Do"]),
                "Done": sumMetrics([jiraMetrics.workItemsInSprintByStatus."Done", azuredevopsBoardsMetrics.workItemsInSprintByStatus."Done"])
            }  
			
		},

        //system specific
		(bitBucketMetrics:  bitBucketMetrics) if (!isEmpty(bitbucketData)),
		(confluenceMetrics: confluenceMetrics) if(!isEmpty(confluenceData)),
		(jenkinsMetrics: jenkinsMetrics) if(!isEmpty(jenkinsData)),        
		(jiraMetrics: jiraMetrics) if(!isEmpty(jiraData)),
		(azuredevopsBoardsMetrics: azuredevopsBoardsMetrics) if(!isEmpty(azureDevOpsBoardsData.payload)),
    	(azureDevopsReposMetrics: azureDevopsReposMetrics)if(!isEmpty(azureDevOpsReposData)),
		(azureDevopsPipelinesMetrics: azureDevopsPipelinesMetrics)if(!isEmpty(azureDevOpsPipelinesData)),
        (splunkMetrics: {totalDashboards: splunkData}) if(!isEmpty(splunkData)),
		 errors: vars.errors
	} filterObject (!isEmpty($))
}
