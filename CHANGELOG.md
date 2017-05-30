# Xill Language - Change Log
All notable changes to this project will be documented in this file

## [3.4.0] - 30-05-2017
### Add
- Interface for RobotLoader (no functional change) [CTC-2121]
- Support for dependency management (no functional change) [CTC-1971]

## [3.3.1] - 20-04-2017
### Fix
- Include casing not checked [CTC-1943]

## [3.3.0] - 13-01-2017
### Change
- Remove 'as' keyword from 'use' statement [CTC-1384]

## [3.2.1] - 03-01-2017
### Fix
- Functions from qualified includes not usable in pipeline functions [CTC-2001]

## [3.2.0] - 16-12-2016
### Add
- Qualified includes for xill libraries using the new `as` keyword [CTC-1946]
- Function overloading based on parameters [CTC-1613]

## [3.1.4] - 24-03-2016
### Add
- Keywords for pipeline processing (`map`, `filter`, `peek`, `collect`, `consume`, `reduce`, `foreach`) [CTC-1454][CTC-1455][CTC-1456][CTC-1458][CTC-1459]

## [3.1.3] - 23-03-2016
### Change
- Terminal id for tokens, to fix exponential operator (`^`) [CTC-1316]

##[3.1.2] - 10-02-2016
### Change
- The syntax of the argument keyword

##[3.1.1] - 08-02-2016
### Fix
- No error on declaring variable that already existed as parameter [CTC-1238]

## [3.1.0] - 28-01-2016
### Add
- do/fail/success/finally blocks for error handling [CTC-1209]
- runBulk command for parallel robot calls [CTC-1273]

## [3.0.43] - 07-01-2016
### Fix
 - Issue where having two compilers at the same time would cause unexpected behavior regarding project folders

## [3.0.42] - 23-12-2015
### Add
 - Option to use multiple packages on a single declaration: use System, String;
