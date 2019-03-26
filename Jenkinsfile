// import the cheribuildProject() step
@Library('ctsrd-jenkins-scripts') _

def archiveTestResults(String buildDir) {
	return {
		archiveArtifacts allowEmptyArchive: false, artifacts: "${buildDir}/test-results.xml", fingerprint: true, onlyIfSuccessful: true
		junit "${buildDir}/test-results.xml"
	}
}

// Use the native compiler instead of CHERI clang so that we can find the ASAN runtime
cheribuildProject(target: 'bodiagsuite', cpu: 'native', skipArtifacts: true,
		buildStage: "Build Linux (insecure)", nodeLabel: 'linux',
		sdkCompilerOnly: true,
		extraArgs: '--bodiagsuite-native/no-use-asan --without-sdk',
		skipTarball: true, runTests: true, noIncrementalBuild: true,
		afterTests: archiveTestResults("bodiagsuite-native-build"))

cheribuildProject(target: 'bodiagsuite', cpu: 'native', skipArtifacts: true,
		buildStage: "Build Linux (ASAN)", nodeLabel: 'linux',
		sdkCompilerOnly: true,
		extraArgs: '--bodiagsuite-native/use-asan --without-sdk',
		skipTarball: true, runTests: true, noIncrementalBuild: true,
		afterTests: archiveTestResults("bodiagsuite-native-asan-build"))
