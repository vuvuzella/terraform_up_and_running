package tests

// the file name needs to be different from the package?

import (
	"testing"
	"tests/Staged"
)

func TestMain(t *testing.T) {
	t.Run("Integration test group", func(t *testing.T) {
		// t.Run("Non staged tests", Nonstaged_test.TestHelloWorldAppStage)
		t.Run("Staged tests", Staged.TestHelloWorldAppStageWithStages)
	})

}
