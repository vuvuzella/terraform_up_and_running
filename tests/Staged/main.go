package Staged

import (
	"fmt"
	"strings"
	"testing"
	"tests/Common"
	"time"

	http_helper "github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
)

func TestHelloWorldAppStageWithStages(t *testing.T) {

	t.Parallel()

	// store function in a short name for convenience
	stage := test_structure.RunTestStage

	// deploy mysql db
	defer stage(t, "teardown_db", func() { teardownDb(t, Common.DbDirStage) })
	stage(t, "deploy_db", func() { deployDb(t, Common.DbDirStage) })

	// deploy hello-world-app
	defer stage(t, "teardown_app", func() { teardownApp(t, Common.AppDirStage) })
	stage(t, "deploy_app", func() { deployApp(t, Common.AppDirStage, Common.DbDirStage) })

	// Run validation stage
	stage(t, "validate_app", func() { stagedValidateHelloApp(t, Common.AppDirStage) })
}

func stagedValidateHelloApp(t *testing.T, appDirStage string) {
	fmt.Println("Running staged Validate")

	helloOpts := test_structure.LoadTerraformOptions(t, appDirStage)

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

func deployApp(t *testing.T, appDirStage string, dbDirStage string) {
	fmt.Println("Running deployApp")

	dbOpts := test_structure.LoadTerraformOptions(t, dbDirStage)
	appOpts := Common.CreateHelloOpts(t, appDirStage, dbOpts)

	test_structure.SaveTerraformOptions(t, appDirStage, appOpts)

	terraform.InitAndApply(t, appOpts)
}

func teardownApp(t *testing.T, appDirStage string) {
	fmt.Println("Running teardownApp")

	appOpts := test_structure.LoadTerraformOptions(t, appDirStage)
	terraform.Destroy(t, appOpts)
}

func deployDb(t *testing.T, dbDirStage string) {
	fmt.Println("Running deployDb")

	dbOpts := Common.CreateDbOpts(t, dbDirStage)

	// Save data to disk so that it can be read back later
	test_structure.SaveTerraformOptions(t, dbDirStage, dbOpts)

	terraform.InitAndApply(t, dbOpts)
}

func teardownDb(t *testing.T, dbDirStage string) {
	fmt.Println("Running teardownDb")

	dbOpts := test_structure.LoadTerraformOptions(t, dbDirStage)

	defer terraform.Destroy(t, dbOpts)
}
