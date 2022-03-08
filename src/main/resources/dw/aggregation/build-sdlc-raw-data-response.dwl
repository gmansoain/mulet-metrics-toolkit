%dw 2.0
output application/json
var bitbucketData = payload[0].payload
var confluenceData = payload[1].payload
var jenkinsData = payload[2].payload
var jiraData = payload[3].payload
var splunkData = payload[4].payload
var azureDevOpsBoardsData = payload[5]
var azureDevOpsReposData = payload[6].payload 
var azureDevOpsPipelinesData = payload[7].payload
---
{
	date: vars.date,
	sdlcData : {
		bitbucketData: bitbucketData,
		confluenceData: confluenceData,
		jenkinsData: jenkinsData,
		jiraData: jiraData,
		splunkData: splunkData,
		azureDevOpsBoardsData: azureDevOpsBoardsData,
		azureDevOpsReposData: azureDevOpsReposData,
		azureDevOpsPipelinesData: azureDevOpsPipelinesData,
		errors: vars.errors	
		}	filterObject (!isEmpty($))
}
