## 0.2.2

- Added DateTimeConversion option to GenericModel.dateTime to allow for seconds and milliseconds conversion

## 0.2.1

- Added loadModels to GenericModelMap for conveniently adding the loadedModels into the local map after a function that loads the models is called.

## 0.2.0

- BREAKING CHANGE: Changed all references to GenericModel to instead reference BaseModel
- Added MappableFields typedef and MapFieldsExtension to make using the getterSetterMap more convenient
- Added MappableModel which implements BaseModel and changed GenericModel to extend that instead

## 0.1.23

- Refactored GenericModel to implement newly created BaseModel instead.
- Moved GenericModel ID functions to BaseModelIDExtension (thus they can no longer be overwritten)
- Moved GenericModel Field functions to BaseModelFieldExtension (thus they can no longer be overwritten)
- Changed all references to GenericModel to instead reference BaseModel -- This is a breaking change, either upgrade to 0.2.0 or downgrade to 0.1.22 if needed.

## 0.1.22

- Added containsRows function to check if a table/container in a database has any values with the same type. This has a default inefficient implementation that can be overridden.

## 0.1.21

- Added getField and setField function to GenericModel
- Changed copy and hasSameFields to use the newly added functions

## 0.1.20

- Added saveModels function to DatabaseRepository and SpecificDatabase with default implementation

## 0.1.19

- Added validator/list.dart to exported libraries

## 0.1.18

- Moved validator to its own subfolder and divided the validator into distinct files
- Added ListSizeValidator
- Added ListSubValidator

## 0.1.17

- Fixed GenericModel.modelList to work when serialized and deserialized

## 0.1.16

- Added DatabaseException and an errorStream to DatabaseRepository
- Added Unit Test for Assertions in GenericModel

## 0.1.15

- Added PastDateTimeValidator

## 0.1.14

- Added GenericModel.number to make handling numbers easier and more consistent.

## 0.1.13

- Added JsonMap extension for reading values from maps.
- Added Validator and ValidatorCollection.
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
