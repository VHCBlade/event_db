## 0.1.13

- Added JsonMap extension for reading values from maps.
- Added Validator and ValidatorCollection
- Added corresponding unit tests.

## 0.1.12

- Changed ArgumentErrors and AssertionErrors thrown by type mismatches in GenericModel throw a FormatException instead.
- Added corresponding unit tests.

## 0.1.11

- Added JsonStringModel to make working with jsonStrings easier.

## 0.1.10+1

- Added search function to SpecificDatabase

## 0.1.10

- Added fieldsToEvaluate and hasSameFields functions to GenericModel
- Added Search function with a default implementation to DatabaseRepository
- Added more tests for better coverage

## 0.1.9

- Added explicit dynamic to the Getters and Setters in GenericModel
- Changed linter to very good analysis and applied the changes recommended.

## 0.1.8

- Fixed Bug that caused GenericModel.model to not work when the map has a null value for that particular entry.

## 0.1.7

- Added idSuffix getter to GenericModel
- Changed idSuffix setter in GenericModel to use String? instead of String 

## 0.1.6

- Added OrdereableModel interface
- Added extension methods to GenericModelMap for ones that have an OrdereableModel

## 0.1.5

- Added findModels function to DatabaseRepository

## 0.1.4+1

- Added missing export for model_map.dart

## 0.1.4

- Added SpecificDatabase to make DatabaseRepository interactions simpler when only using a single databaseName
- Added GenericModelMap to hold some convenience function for loading maps.

## 0.1.3

- Added FakeDatabaseRepository
- Added Method for prefixing
- Changed DatabaseRepository abstract functions to be FutureOrs instead of strictly Futures

## 0.1.2

- Added helper functions in GenericModel for creating the Getters and Setters for DateTimes and Primitives

## 0.1.1

- Added helper functions in GenericModel for creating the Getters and Setters for GenericModels

## 0.1.0

- Initial version.
