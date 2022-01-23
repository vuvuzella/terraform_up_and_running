package Common

import (
	"fmt"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

const (
	// Private constants
	environment = "integration"
	stateBucket = "admin-dev-tf-state"
	dbLockTable = "terraform-up-and-running-locks"
	region      = "ap-southeast-2"
	profile     = "admin-dev"

	mysqlStateKey = "integration/data-stores/mysql/terraform.tfstate"
	appStateKey   = "integration/services/hello-world-app/terraform.tfstate"

	// Global constants
	// TODO: use Executable to get file path of the executable
	DbDirStage  = "../stage/data-stores/mysql"
	AppDirStage = "../stage/services/hello-world-app"
)

func CreateDbOpts(t *testing.T, dbDirStage string) *terraform.Options {
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

func CreateHelloOpts(t *testing.T, appDirStage string, dbOpts *terraform.Options) *terraform.Options {

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
			"environment":            dbOpts.Vars["db_name"],
			"server_text":            "Hello Integration Test",
			"db_remote_state_bucket": dbOpts.BackendConfig["bucket"],
			"db_remote_state_key":    dbOpts.BackendConfig["key"],
		},

		// Retry deployment and number between retries
		MaxRetries:         5,
		TimeBetweenRetries: 5 * time.Second,
		RetryableTerraformErrors: map[string]string{
			"RequestError: send request failed": "Throttling issue?",
		},
	}
}
