// Author / Project Supervisor : Omar Terro
// GitHub                      : https://github.com/IOTERRO
// Website                     : https://omarterro.fr
// Student (FYP)               : Khaled Othman
// Date                        : 14 October 2026
// Project                     : SmartUni - Smart University CityU
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
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
