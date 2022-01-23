package Nonstaged

// the file name needs to be different from the package?

import (
	"fmt"
	"strings"
	"testing"
	"tests/Common"
	"time"

	http_helper "github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

const ()

func TestHelloWorldAppStage(t *testing.T) {

	// deploy the database
	dbOpts := Common.CreateDbOpts(t, Common.DbDirStage)
	defer terraform.Destroy(t, dbOpts)
	terraform.InitAndApply(t, dbOpts)

	// deploy hello-world-app
	helloOpts := Common.CreateHelloOpts(t, Common.AppDirStage)
	defer terraform.Destroy(t, helloOpts)
	terraform.InitAndApply(t, helloOpts)

	// validate hello world app works
	validateHelloApp(t, helloOpts)

}

func validateHelloApp(t *testing.T, helloOpts *terraform.Options) {
	albDnsName := terraform.OutputRequired(t, helloOpts, "alb_dns_name")
	url := fmt.Sprintf("http://%s", albDnsName)

	maxRetries := 5
	timeBetweenRetries := 10 * time.Second

	http_helper.HttpGetWithRetryWithCustomValidation(
		t,
		url,
		nil,
		maxRetries,
		timeBetweenRetries,
		func(status int, body string) bool {
			return status == 200 && strings.Contains(body, "Hello Integration Test")
		},
	)
}
