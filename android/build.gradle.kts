allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url = uri("https://artifactory.img.ly/artifactory/maven") }
    }
}

val androidCompileSdk = 36

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    // Some hosted Flutter plugins pin compileSdk lower than their AndroidX dependencies require.
    afterEvaluate {
        extensions.findByName("android")?.let { androidExtension ->
            androidExtension.javaClass.methods
                .firstOrNull {
                    val parameterType = it.parameterTypes.singleOrNull()
                    it.name == "setCompileSdk" &&
                        (parameterType == Int::class.javaPrimitiveType ||
                            parameterType == Int::class.javaObjectType)
                }?.invoke(androidExtension, androidCompileSdk)
                ?: androidExtension.javaClass.methods
                    .firstOrNull {
                        val parameterType = it.parameterTypes.singleOrNull()
                        it.name == "compileSdkVersion" &&
                            (parameterType == Int::class.javaPrimitiveType ||
                                parameterType == Int::class.javaObjectType)
                    }?.invoke(androidExtension, androidCompileSdk)
        }
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
