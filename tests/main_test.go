package tests

// the file name needs to be different from the package?

import (
	"fmt"
	"strings"
	"testing"
	"time"

	http_helper "github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

const (
	environment = "integration"
	dbDirStage  = "../stage/data-stores/mysql"
	appDirStage = "../stage/services/hello-world-app"
	stateBucket = "admin-dev-tf-state"
	dbLockTable = "terraform-up-and-running-locks"
	region      = "ap-southeast-2"
	profile     = "admin-dev"

	mysqlStateKey = "integration/data-stores/mysql/terraform.tfstate"
	appStateKey   = "integration/services/hello-world-app/terraform.tfstate"
)

func TestHelloWorldAppStage(t *testing.T) {

	// deploy the database
	dbOpts := createDbOpts(t, dbDirStage)
	defer terraform.Destroy(t, dbOpts)
	terraform.InitAndApply(t, dbOpts)

	// deploy hello-world-app
	helloOpts := createHelloOpts(t, appDirStage)
	defer terraform.Destroy(t, helloOpts)
	terraform.InitAndApply(t, helloOpts)

	// validate hello world app works
	validateHelloApp(t, helloOpts)

}

func createDbOpts(t *testing.T, dbDirStage string) *terraform.Options {
	uuid := random.UniqueId()

	dbSecret := "mysql-master-password-stage"

	return &terraform.Options{
		TerraformDir: dbDirStage,
		Vars: map[string]interface{}{
			"db_name":                fmt.Sprintf("StageMysqlDb%s", uuid),
			"db_password_secrets_id": dbSecret,
		},
		BackendConfig: map[string]interface{}{
			"bucket":         stateBucket,
			"key":            mysqlStateKey,
			"region":         region,
			"dynamodb_table": dbLockTable,
			"encrypt":        true,
			"profile":        profile,
		},
		Reconfigure: true, // so that cached states can be safely ignored and proceed with the state defined in this test file
	}
}

// TODO: make this run without terragrunt!
func createHelloOpts(t *testing.T, appDirStage string) *terraform.Options {

	return &terraform.Options{
		// TerraformBinary: "terragrunt", Unfortunately terragrunt does not append the reconfigure when doing terragrunt apply
		TerraformDir: appDirStage,
		Reconfigure:  true,
		BackendConfig: map[string]interface{}{
			"bucket":         stateBucket,
			"key":            appStateKey,
			"region":         region,
			"dynamodb_table": dbLockTable,
			"encrypt":        true,
			"profile":        profile,
		},
		Vars: map[string]interface{}{
			"environment":            "integration-test",
			"server_text":            "Hello Integration Test",
			"db_remote_state_bucket": stateBucket,
			"db_remote_state_key":    mysqlStateKey,
		},
	}
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
