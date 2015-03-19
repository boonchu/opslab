#!/usr/bin/env bats

@test "java is found in PATH" {
  run which java
  [ "$status" -eq 0 ]
}

# stackoverflow.com case
# http://stackoverflow.com/questions/7334754/correct-way-to-check-java-version-from-bash-script
@test "using java jdk 6 or 7" {
  result="$(java -version 2>&1 | sed 's/java version "\(.*\)\.\(.*\)\..*"/\1\2/; 1q')"
  [ "$result" -eq 17 ] || [ "$result" -eq 16 ]
}

@test "tomcat process is visible " {
  result=$(ps aux | grep java | grep tomcat|wc -l)
  [ "$result" -eq 1 ]
}

@test "war is placed in proper location " {
  run [ -f /var/lib/tomcat6/webapps/punter.war ]
  [ "$status" -eq 0 ]
}

@test "war is unrolled" {
  run [ -d /var/lib/tomcat6/webapps/punter ]
  [ "$status" -eq 0 ]
}
