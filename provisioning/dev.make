core = 8.x
api = 2

; Core
projects[drupal][version] = "8.x"

; Common settings for modules
defaults[projects][subdir] = "contrib"
defaults[projects[type] = "module"
defaults[projects][download][type] = "git"

; Development
projects[coder][download][url] = "http://git.drupal.org/project/coder.git"
projects[coder][download][branch] = "8.x-2.x"

projects[devel][download][url] = "http://git.drupal.org/project/devel.git"
projects[devel][download][branch] = "8.x-1.x"

projects[webprofiler][download][url] = "http://git.drupal.org/project/webprofiler.git"
projects[webprofiler][download][branch] = "8.x-1.x"

; CMI
projects[config_inspector][download][url] = "http://git.drupal.org/project/config_inspector.git"
projects[config_inspector][download][branch] = "8.x-1.x"

projects[config_devel][download][url] = "http://git.drupal.org/project/config_devel.git"
projects[config_devel][download][branch] = "8.x-1.x"

; REST
projects[restui][download][url] = "http://git.drupal.org/project/restui.git"
projects[restui][download][branch] = "8.x-1.x"
