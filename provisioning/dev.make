core = 8.x
api = 2

; Core
projects[drupal][version] = "8.x"

; Modules
defaults[projects][subdir] = "contrib"
defaults[projects[type] = "module"
defaults[projects][download][type] = "git"

projects[coder][download][url] = "http://git.drupal.org/project/coder.git"
projects[coder][download][branch] = "8.x-2.x"

projects[devel][download][url] = "http://git.drupal.org/project/devel.git"
projects[devel][download][branch] = "8.x-1.x"

projects[webprofiler][download][url] = "http://git.drupal.org/project/webprofiler.git"
projects[webprofiler][download][branch] = "8.x-1.x"
