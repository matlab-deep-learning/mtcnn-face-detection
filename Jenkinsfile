pipeline {
    agent any
    environment {
        PATH = "${PATH}:/Applications/MATLAB_R2020a.app/bin"
    }
    stages {
        stage('Run the MATLAB tests') {
            steps {
                runMATLABTests(
                    testResultsJUnit: 'matlabTestArtifacts/junittestresults.xml',
                    codeCoverageCobertura: 'matlabTestArtifacts/cobertura.xml'
                    )
                junit 'matlabTestArtifacts/junittestreport.xml'
            }
        }
    }
}
