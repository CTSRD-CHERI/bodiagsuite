// import the cheribuildProject() step
@Library('ctsrd-jenkins-scripts') _

def archiveTestResults(String testSuffix) {
    return {
        String outputXml = "test-results-${testSuffix}.xml"
        sh """
rm -f ${outputXml}
ls -la bodiagsuite-*-build/test-results.xml
mv -f bodiagsuite-*-build/test-results.xml ${outputXml}
"""
        archiveArtifacts allowEmptyArchive: false, artifacts: "${outputXml}", fingerprint: true, onlyIfSuccessful: false
        // Only record junit results for cases where all tests should pass
        // (ignore insecure native runs)
        if (testSuffix.contains("-subobject")) {
                junit "${outputXml}"
        }
        // Cleanup after archiving the test results
        sh 'rm -rf bodiagsuite-*-build'
    }
}

def process(String cpu, String xmlSuffix, Map args) {
    if (cpu == "cheri128") {
    } else if (cpu == "native" || cpu == "mips") {
        if (args["extraArgs"].contains('/no-use-asan')) {
        } else {
            assert (args["extraArgs"].contains('/use-asan'))
        }
    } else {
        error("Invalid cpu: ${cpu}")
    }
    def commonArgs = [target     : 'bodiagsuite', cpu: cpu,
                      skipScm    : false, nodeLabel: null,
                      skipTarball: true, runTests: true,
                      afterTests : archiveTestResults(cpu + "-" + xmlSuffix),
                      useCheriKernelForMipsTests: true,
                      beforeSCM: { sh 'rm -rf bodiagsuite-*-build *.xml' } ]
    if (cpu == "native") {
        // Use the native compiler instead of CHERI clang so that we can find the ASAN runtime (--without-sdk)
        commonArgs["skipArtifacts"] = true
        commonArgs["sdkCompilerOnly"] = true
        assert (args["extraArgs"].contains('--without-sdk'))
    }
    echo("args = ${commonArgs + args}")
    node("docker") {
        dir ("bodiagsuite") { checkout scm }
        docker.build("test-image", "bodiagsuite/docker/opensuse").inside {
               cheribuildProject(commonArgs + args)
        }
    }
}

def jobs = [
// native
"Linux (insecure)"               : {
    process('native', 'insecure',
            [stageSuffix: "Linux (insecure)", extraArgs: '--bodiagsuite/no-use-asan --without-sdk'])
},
"Linux (fortify)"                : {
    process('native', 'fortify-source',
            [stageSuffix: "Linux (_FORTIFY_SOURCE)",
             extraArgs  : '--bodiagsuite/no-use-asan --without-sdk --bodiagsuite/use-fortify-source'])
},
"Linux (stack-protector)"        : {
    process('native', 'stack-protector',
            [stageSuffix: "Linux (stack-protector)",
             extraArgs  : '--bodiagsuite/no-use-asan --without-sdk --bodiagsuite/use-stack-protector'])
},
"Linux (stack-protector+fortify)": {
    process('native', 'stack-protector-and-fortify-source',
            [stageSuffix: "Linux (stack-protector+_FORTIFY_SOURCE)",
             extraArgs  : '--bodiagsuite/no-use-asan --without-sdk --bodiagsuite/use-stack-protector --bodiagsuite/use-fortify-source'])
},

// native+ASAN
"Linux (ASAN)"                   : {
    process('native', 'asan',
            [stageSuffix: "Linux (ASAN)",
             extraArgs  : '--bodiagsuite/use-asan --without-sdk'])
},
"Linux (ASAN+sp+fortify)"        : {
    process('native', 'asan-stack-protector-fortify-source',
            [stageSuffix: "Linux (ASAN+stack-protector+_FORTIFY_SOURCE)",
             extraArgs  : '--bodiagsuite/use-asan --without-sdk --bodiagsuite/use-stack-protector --bodiagsuite/use-fortify-source'])
},

// native+Valgrind
"Linux (Valgrind)"                : {
    process('native', 'valgrind',
            [stageSuffix: "Linux (Valgrind)",
             extraArgs  : '--bodiagsuite/no-use-asan --bodiagsuite/use-valgrind --without-sdk'])
},
"Linux (Valgrind+sp+fortify)"     : {
    process('native', 'valgrind-stack-protector-fortify-source',
            [stageSuffix: "Linux (Valgrind+stack-protector+_FORTIFY_SOURCE)",
             extraArgs  : '--bodiagsuite/no-use-asan --bodiagsuite/use-valgrind --without-sdk --bodiagsuite/use-stack-protector --bodiagsuite/use-fortify-source'])
},

// MIPS:
"FreeBSD MIPS (insecure)"        : {
    process('mips', 'insecure',
            [stageSuffix: "FreeBSD MIPS (insecure)",
             extraArgs  : '--bodiagsuite-mips/no-use-asan'])
},

//"FreeBSD MIPS (ASAN)"            : {
//    process('mips', 'asan',
//            [stageSuffix: "FreeBSD MIPS (ASAN)",
//             extraArgs  : '--bodiagsuite-mips/use-asan'])
//},


// CHERI128
"CheriABI"                       : {
    process('cheri128', 'cheriabi',
            [stageSuffix: "CHERI128",
             extraArgs  : ''])
},
"CheriABI+subobject-safe"        : {
    process('cheri128', 'subobject-safe',
            [stageSuffix: "CHERI128 (subobject safe)",
             extraArgs  : '--subobject-bounds=subobject-safe'])
},
"CheriABI+subobject-everywhere"  : {
    process('cheri128', 'subobject-everywhere',
            [stageSuffix: "CHERI128 (subobject everywhere)",
             extraArgs  : '--subobject-bounds=everywhere-unsafe'])
}
]
// print(jobs)
boolean runParallel = false;
if (runParallel) {
    jobs.failFast = true
    parallel jobs
} else {
    jobs.each { key, value ->
        echo("RUNNING $key")
        value();
    }
}
