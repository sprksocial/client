allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url = uri("https://artifactory.img.ly/artifactory/imgly") }
    }
}

buildscript {
    val kotlinVersion = "1.7.21"
    repositories {
        google()
        mavenCentral()
        maven { url = uri("https://artifactory.img.ly/artifactory/imgly") }
    }
    dependencies {
        classpath("com.google.devtools.ksp:com.google.devtools.ksp.gradle.plugin:1.7.21-1.0.8")
        classpath("ly.img.android.sdk:plugin:10.9.0")
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
