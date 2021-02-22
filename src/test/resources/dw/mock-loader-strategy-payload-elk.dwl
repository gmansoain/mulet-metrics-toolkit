%dw 2.0
output application/json
---
{
	loaderDetails: {
		strategy: "elk",
		rawData: "false",
		elk: {
			host: "https://myelk.com",
			port: "7000",
			user: "user",
			password: "123",
			platformMetricsIndex: "metrics",
			platformBenefitsIndex: "platform_benefits"
		}
	}
}