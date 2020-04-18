// everything in the groovy language runs on the Jenkins master
// anything inside the 'steps' closure will run on specified agents
// if there is a 'script' closure inside 'steps', groovy code will still run on the master

// global variable
def junitPath = 'target/surefire-reports/*.xml'

pipeline {
    // default agent for stages
    // stages can have different agents
    agent {
        kubernetes {
            // yamlFile tells Jenkins to use a k8s yaml file as a template to create a slave pod
            // the default container to use is jnlp
            yamlFile 'k8s-pod-templates/maven.yaml'
        }
    }
    // job parameters
    parameters {
        string(name: 'MESSAGE',
               defaultValue: 'Hello, World!',
               description: 'Message to print at the end of the pipeline')
        string(name: 'imageTag',
               defaultValue: 'ala-artifactory.wrs.com/docker-devstar/simple-java-maven-app:1.0.0',
               description: 'Tag for the Docker image to build')
    }
    // each stage is displayed in the Stage View when viewing the job
    // a failure in one stage causes the entire build to stop and fail
    stages {
        stage('Get Dependencies') {
            steps {
                // this will run in the jnlp container
                // directories are relative to the WORKSPACE environment variable
                dir('simple-java-maven-app') {
                    git branch: 'master', url: 'https://github.com/jenkins-docs/simple-java-maven-app.git'
                }
            }
        }
        stage('Build Dependencies') {
            steps {
                container('maven') {
                    dir('simple-java-maven-app') {
                        // sh runs a shell command in the slave container
                        // single quotes DO NOT allow variable interpolation
                        sh 'mvn -B -DskipTests clean package'
                    }
                }
            }
        }
        stage('Test Dependencies') {
            steps {
                container('maven') {
                    dir('simple-java-maven-app') {
                        sh 'mvn test'
                    }
                }
            }
            // steps after stage
            post {
                always {
                    dir('simple-java-maven-app') {
                        // double quotes allow for variable interpolation
                        junit "${junitPath}"
                        // if the variable is not being concatenated, this syntax also works:
                        // junit junitPath
                    }
                }
            }
        }
        stage('Build Docker Image') {
            agent {
                kubernetes {
                    yamlFile 'k8s-pod-templates/docker.yaml'
                }
            }
            steps {
                container('docker') {
                    // multiline string with support for varialbe interpolation
                    sh """
                    docker build -t ${imageTag} -f Dockerfile .
                    docker push ${imageTag}
                    """
                }
            }
            post {
                success {
                    echo MESSAGE
                }
            }
        }
    }
}
