package tests

import (
	"testing"

	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
)

func TestHelloWorldAppStageWithStages(t *testing.T) {
	t.Parallel()

	// store function in a short name for convenience
	stage := test_structure.RunTestStage

	defer stage(t, "teardown_db", func() { teardownDb(t, dbDirStage) })

}

func teardownDb(t *testing.T, dbDirStage string) {

}
