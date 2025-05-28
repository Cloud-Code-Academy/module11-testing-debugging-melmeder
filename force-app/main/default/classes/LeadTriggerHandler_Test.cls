@IsTest
public with sharing class LeadTriggerHandler_Test {
    // @TestSetup
    // static void makeData(){
    //     List<Lead> leadsToInsert = new List<Lead>();
    //     for (Integer i = 0; i < 10; i++) {
    //         Lead ld = new Lead(Company = 'Test Company', LastName = 'Test' + i);
    //         leadsToInsert.add(ld);
    //     }
    //     insert leadsToInsert;
    // }

    @IsTest
    public static void handleTitleNormalization_onInsertPositiveVicePresident() {
        Lead ld = new Lead(Company = 'Test Company', LastName = 'Test', Title = 'v.p. of sales');
        insert ld;
        Lead ldCheck = [SELECT Id, Title FROM Lead];
        Assert.areEqual('Vice President', ldCheck.Title, 'Title was not normalized.');
    }

    @IsTest
    public static void handleTitleNormalization_onInsertPositiveManager() {
        Lead ld = new Lead(Company = 'Test Company', LastName = 'Test', Title = 'head of department - marketing');
        insert ld;
        Lead ldCheck = [SELECT Id, Title FROM Lead];
        Assert.areEqual('Manager', ldCheck.Title, 'Title was not normalized.');
    }

    @IsTest
    public static void handleTitleNormalization_onInsertPositiveExecutive() {
        Lead ld = new Lead(Company = 'Test Company', LastName = 'Test', Title = 'Chief Executive Officer');
        insert ld;
        Lead ldCheck = [SELECT Id, Title FROM Lead];
        Assert.areEqual('Executive', ldCheck.Title, 'Title was not normalized.');
    }

    @IsTest
    public static void handleTitleNormalization_onUpdatePositive() {
        Lead ld = new Lead(Company = 'Test Company', LastName = 'Test', Title = 'v.p. of sales');
        insert ld;
        Lead ldCheck = [SELECT Id, Title FROM Lead];
        ldCheck.Title = 'jr. dev';
        update ldCheck;
        Lead updatedLead = [SELECT Id, Title FROM Lead];
        Assert.areEqual('Assistant', updatedLead.Title, 'Title was not normalized.');
    }

    @IsTest
    public static void handleTitleNormalization_negative() {
        Lead ld = new Lead(Company = 'Test Company', LastName = 'Test', Title = 'CEO');
        insert ld;
        Lead ldCheck = [SELECT Id, Title FROM Lead];
        Assert.areEqual('CEO', ldCheck.Title, 'Title was adjusted when it should not have been.');
    }

    @IsTest
    public static void handleAutoLeadScoring_positive() {
        Lead ld = new Lead(
            Company = 'Test Company', 
            LastName = 'Test', 
            Email = 'fake@fake.com', 
            LeadSource = 'Website', 
            Phone = '867-5309', 
            Industry = 'Technology'
        );
        insert ld;

        Lead insertedLead = [SELECT Id, Lead_Score__c FROM Lead WHERE Id = :ld.Id];
        Assert.areEqual(18, insertedLead.Lead_Score__c, 'Wrong Lead Score value.');
    }

    @IsTest
    public static void handleLeadAutoConvert_positive() {

        insert new Account(Name = 'Test Account');
        Account insertedAcct = (Account)[SELECT Id FROM Account LIMIT 1];
        Id acctId = insertedAcct.Id;

        Contact ct = new Contact(
            AccountId = acctId, 
            LastName = 'Test', 
            Email = 'fake@fake.com'
        );
        insert ct;

        Lead ld = new Lead(
            Company = 'Test Company', 
            LastName = 'Test', 
            Email = 'fake@fake.com'
        );
        insert ld;

        Lead leadCheck = [SELECT Id, IsConverted FROM Lead LIMIT 1];

        Assert.areEqual(true, leadCheck.IsConverted, 'Lead was not converted as expected.');
    }

    @IsTest
    public static void handleLeadAutoConvert_negativeNonmatchingEmail() {
        insert new Lead(FirstName = 'Unmatched', LastName = 'Lead', Email = 'nomatch@example.com', Company = 'Not Matching');

        Lead ld = [SELECT Id, IsConverted FROM Lead LIMIT 1];

        Assert.areEqual(false, ld.IsConverted, 'Lead should not have been converted.');
    }

    @IsTest
    public static void handleLeadAutoConvert_negativeNullEmail() {
        insert new Lead(FirstName = 'Unmatched', LastName = 'Lead', Company = 'Not Matching');

        Lead ld = [SELECT Id, IsConverted FROM Lead LIMIT 1];

        Assert.areEqual(false, ld.IsConverted, 'Lead should not have been converted.');
    }
}