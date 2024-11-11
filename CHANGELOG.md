# CHANGELOG

This file contains all the latest changes and updates to this application.

## 1.2.2

### Bug Fixes

- support for irregular dns types ([d74487](https://github.com/krystal/dennis-client/commit/d74487cceee566cd45f0b98f2d6bbf29aa526ae6))

## 1.2.1

### Bug Fixes

- ensure CI can publish the gem ([caa635](https://github.com/krystal/dennis-client/commit/caa635104aed8fb79237991b8cc06f0ebc32a5d3))

## 1.2.0

### Features

- add support for new POST zones/:zone/verify endpoint ([00078e](https://github.com/krystal/dennis-client/commit/00078ea660ca886c4ddb1b78f522fcb5e67bad90))

## 1.1.1

## 1.1.0

## 1.0.21

### Bug Fixes

- ensure options are passed from controller to underlying classes ([ebc52c](https://github.com/krystal/dennis-client/commit/ebc52cf6a126686ec953f9119b218543cff0ba97))

## 1.0.20

### Features

- add support for querying tags on zones ([ed318d](https://github.com/krystal/dennis-client/commit/ed318dbb59b6f708de95cd61fe2f75dacb431716))

## 1.0.19

### Features

- add Zone#verify_nameservers ([3bf802](https://github.com/krystal/dennis-client/commit/3bf8022295ddb296364c3d2611fdbce442b51083))

## 1.0.18

### Features

- add RecordType#exposed? ([3c2b3f](https://github.com/krystal/dennis-client/commit/3c2b3fb2fd555299b189f36233214d33df419579))

## 1.0.17

### Features

- add Zone#record to lookup specific records in a zone ([363a21](https://github.com/krystal/dennis-client/commit/363a21c12994a379665770e63aab1e2569b33c26))

## 1.0.16

### Features

- add Record#display_content ([d64da6](https://github.com/krystal/dennis-client/commit/d64da655e7f9e96c39d9af0f853e2bd8c32ddaa9))

## 1.0.15

### Features

- add Record#raw_content ([459779](https://github.com/krystal/dennis-client/commit/459779748ac9dbbfc8529d1b8702f7d0b61898f9))

## 1.0.14

### Bug Fixes

- remove pagination from records ([9aecff](https://github.com/krystal/dennis-client/commit/9aecff826840f4aa6ab7a56957ca23ba1f90651f))

## 1.0.13

### Bug Fixes

- improve Record.all ([9f0576](https://github.com/krystal/dennis-client/commit/9f05760bd8ef8643490babdf27074926f2210681))

## 1.0.12

### Features

- add a few extra helper methods ([dac9cc](https://github.com/krystal/dennis-client/commit/dac9ccb7043c0998c4fe922d4cb83f96206cff45))

## 1.0.11

### Bug Fixes

- support for tags ([1c72c0](https://github.com/krystal/dennis-client/commit/1c72c01e5a952905ab51b1f68efa9b6c8a2df6fc))

## 1.0.10

### Features

- add record types ([e6e805](https://github.com/krystal/dennis-client/commit/e6e805c9fb2d9d73a40fd388d5d172cf51ef1e22))

## 1.0.9

### Features

- support for pagination ([975a39](https://github.com/krystal/dennis-client/commit/975a39ae60cb922cb629a00237a2f8020bfad449))
- support for tagged records ([fe8e46](https://github.com/krystal/dennis-client/commit/fe8e464696fa140bbdba33674c75186ad9c38836))

## 1.0.8

### Bug Fixes

- expose Record#managed? and timestamps for other objects ([9d0a08](https://github.com/krystal/dennis-client/commit/9d0a08ed9eabcd5360657b59507d0336a712ae93))

## 1.0.7

### Bug Fixes

- add #record method to client ([d15fd7](https://github.com/krystal/dennis-client/commit/d15fd7b6fae8a1cd74023b01969358ebe053ab15))

## 1.0.6

### Features

- some new view options for records & zones ([467371](https://github.com/krystal/dennis-client/commit/46737144591b18dba82d6054041324c3818c8372))
- various improvements to bring inline with new API ([a04bac](https://github.com/krystal/dennis-client/commit/a04bac1c9ad1ce2f04b38102693d5befc0c2b69b))

## 1.0.5

### Bug Fixes

- support for other properties on zone ([c8ad49](https://github.com/krystal/dennis-client/commit/c8ad4958c6bfff44c0a1adc5cfe591b921177f17))

## 1.0.4

### Bug Fixes

- fixes Zone.all_for_group ([165edd](https://github.com/krystal/dennis-client/commit/165eddaf8b77e19f9f38b71446445c75056af972))

## 1.0.3

### Bug Fixes

- pass through options to the rapid API ([11fc19](https://github.com/krystal/dennis-client/commit/11fc190cdec2ffb5e3a0a3b67eb14d6fca36d30b))

## 1.0.2

### Features

- support for managing nameservers ([43e908](https://github.com/krystal/dennis-client/commit/43e908545a5f67768c14c16a0cdfa154b6cfd64a))

## 1.0.1

## 1.0.0

### Features

- add nameserver verification to client ([510b1c](https://github.com/krystal/dennis-client/commit/510b1ccc8d8bf6c21107ccafaba86e28bd8b7740))
- zone management ([759aba](https://github.com/krystal/dennis-client/commit/759abae5b045ea4513c714af22a14e959acdb9c8))

## 1.1.0

### Features

- add nameserver verification to client ([510b1c](https://github.com/krystal/dennis-client/commit/510b1ccc8d8bf6c21107ccafaba86e28bd8b7740))
- zone management ([759aba](https://github.com/krystal/dennis-client/commit/759abae5b045ea4513c714af22a14e959acdb9c8))
