%dw 2.0
output application/java
var sources = if (isEmpty(payload.collectors)) "all" else payload.collectors
---
{
	bitbucket: {
		enabled: (sources ==  'all') or (sources contains 'bitbucket')
	}
    ,
	jira: {
		enabled: (sources ==  'all') or (sources contains 'jira')
	},
	confluence: {
		enabled: (sources ==  'all') or (sources contains 'confluence')
	},
	jenkins: {
		enabled: (sources ==  'all') or (sources contains 'jenkins')
	},
	splunk: {
		enabled: (sources ==  'all') or (sources contains 'splunk')
	},
	azuredevops: {
		repos: {
			enabled: (sources ==  'all') or (sources contains 'adRepos')
		},
		pipelines: {
			enabled: (sources ==  'all') or (sources contains 'adPipelines')
		},
		boards:{
			enabled: (sources ==  'all') or (sources contains 'adBoards')
		}
	}	
}