%dw 2.0
output application/java
---
{
	bitbucket: {
		enabled: p('sdlc.bitbucket.enabled')
	},
	jira: {
		enabled: p('sdlc.jira.enabled')
	},
	confluence: {
		enabled: p('sdlc.confluence.enabled')
	},
	jenkins: {
		enabled: p('sdlc.jenkins.enabled')
	},
	splunk: {
		enabled: p('sdlc.splunk.enabled')
	},
	azuredevops: {
		repos: {
			enabled: p('sdlc.azuredevops.repos.enabled')
		},
		pipelines: {
			enabled: p('sdlc.azuredevops.pipelines.enabled')
		},
		boards:{
			enabled: p('sdlc.azuredevops.boards.enabled')
		}
	}
	
}