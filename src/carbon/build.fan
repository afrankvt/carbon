#! /usr/bin/env fan

using build

class Build : build::BuildPod
{
  new make()
  {
    podName = "carbon"
    summary = "Carbon ORM for SQL databases"
    version = Version("0.1")
    meta = [
      "license.name": "MIT",
      "vcs.name":     "Git",
      "vcs.uri":      "https://github.com/afrankvt/carbon",
      "repo.public":  "true",
      "repo.tags":    "database",
    ]
    depends = ["sys 1.0", "util 1.0", "concurrent 1.0", "sql 1.0"]
    srcDirs = [`fan/`, `test/`]
    // resDirs = [`doc/`]
    docApi  = true
    docSrc  = true
  }
}
