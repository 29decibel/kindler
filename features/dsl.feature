Feature: Generate mobi book using dsl

Scenario: create simple mobi books
 Given new a Kindle book instance
 When call generate of that book instance
 Then got a mobi book

 
