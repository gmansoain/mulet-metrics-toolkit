%dw 2.0
output application/json
---
{
  "query": "Select [System.Id] From WorkItems Where [Team Project] = @Project"
}