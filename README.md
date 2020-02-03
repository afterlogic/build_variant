
        flutter pub run build_variant "optional path to build_variant.yaml"

# build_variant.yaml

build_variant.yaml contains variables.
project must have his in root folder with fields:

        _files:
          - "pubspec.yaml.temp"
          - "{{any file}}.dart.temp"

        _buildPropertyPath: lib/build_const.dart

_files - in this files inserting variables and after they create with not last extension

_buildPropertyPath - file for create dart class with list variables from build_variant.yaml

if you not need add you variable for _buildPropertyPath add "_" prefix, like this "_variable"

you can override build_variant.yaml variables from other file
call "pub run build_variant "path to other build_variant.yaml""

# template operators

        {{"some variable"}}

in template file you can insert {{"some variable"}} and in created file this text replaced to variable value
works in variables

        //if : some variable
        code
        //end : if

removes code between operators, if the condition is not true
if you not set //end : if, removes only first line
you can usage "!" for negative, like this "!variable"

# base variables

_dir - folder where build_variant.yaml is located