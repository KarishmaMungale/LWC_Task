public with sharing class DashboardControllerTest {
    private static final Integer MAX_MAP_ROWS = 500;
    private static final Integer MAX_AGGREGATE_ROWS = 200;

    public class FilterCriteria {
        @AuraEnabled
        public String startDate;
        @AuraEnabled
        public String endDate;
        @AuraEnabled
        public String ownerId;
        @AuraEnabled
        public String stageName;
        @AuraEnabled
        public Long refreshToken;
    }

    public class MetricsDto {
        @AuraEnabled
        public Integer openCount;
        @AuraEnabled
        public Decimal openAmount;
        @AuraEnabled
        public Integer wonCount;
        @AuraEnabled
        public Integer lostCount;
        @AuraEnabled
        public List<StageSlice> stageSlices;
    }

    public class StageSlice {
        @AuraEnabled
        public String stageName;
        @AuraEnabled
        public Integer recordCount;
        @AuraEnabled
        public Decimal totalAmount;
    }

    public class AccountLocationDto {
        @AuraEnabled
        public Id accountId;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public Decimal latitude;
        @AuraEnabled
        public Decimal longitude;
    }

    public class AccountLocationResult {
        @AuraEnabled
        public List<AccountLocationDto> records;
        @AuraEnabled
        public Integer totalWithGeo;
        @AuraEnabled
        public Boolean truncated;
    }

    // Discrete params: imperative LWC calls with a single custom-type arg often deserialize all-null (cacheable Apex).
    @AuraEnabled(cacheable=true)
    public static MetricsDto getDashboardMetrics(
        String startDate,
        String endDate,
        String ownerId,
        String stageName,
        Long refreshToken
    ) {
        Date sd = parseDate(startDate);
        Date ed = parseDate(endDate);
        Id oid = parseId(ownerId);
        String stage = resolveStageName(stageName);

        MetricsDto dto = new MetricsDto();
        dto.openCount = aggregateCount(false, false, sd, ed, oid, stage);
        dto.openAmount = aggregateSum(false, false, sd, ed, oid, stage);
        dto.wonCount = aggregateCount(true, true, sd, ed, oid, stage);
        dto.lostCount = aggregateCount(true, false, sd, ed, oid, stage);
        dto.stageSlices = aggregateByStage(sd, ed, oid, stage);
        return dto;
    }

    @AuraEnabled(cacheable=true)
    public static AccountLocationResult getAccountLocations(FilterCriteria filters, Integer rowLimit, Integer rowOffset) {
        FilterCriteria safe = filters == null ? new FilterCriteria() : filters;
        Integer limitSize = rowLimit == null || rowLimit < 1 ? MAX_MAP_ROWS : Math.min(rowLimit, MAX_MAP_ROWS);
        Integer offsetSize = rowOffset == null || rowOffset < 0 ? 0 : rowOffset;

        Date startDate = parseDate(safe.startDate);
        Date endDate = parseDate(safe.endDate);
        Id ownerId = parseId(safe.ownerId);
        String stage = resolveStageName(safe.stageName);

        Boolean useOppJoin =
            ownerId != null || startDate != null || endDate != null || String.isNotBlank(stage);

        String geoClause = 'BillingLatitude != NULL AND BillingLongitude != NULL';
        Map<String, Object> oppBinds = new Map<String, Object>();
        String joinClause = '';
        if (useOppJoin) {
            joinClause =
                ' AND Id IN (SELECT AccountId FROM Opportunity WHERE AccountId != NULL' +
                appendOpportunityFilters(startDate, endDate, ownerId, stage, oppBinds) +
                ')';
        }

        String countSoql = 'SELECT COUNT() FROM Account WHERE ' + geoClause + joinClause;
        String dataSoql =
            'SELECT Id, Name, BillingLatitude, BillingLongitude FROM Account WHERE ' +
            geoClause +
            joinClause +
            ' ORDER BY Name LIMIT :limitSize OFFSET :offsetSize';

        Map<String, Object> binds = new Map<String, Object>();
        binds.put('limitSize', limitSize);
        binds.put('offsetSize', offsetSize);
        if (useOppJoin) {
            binds.putAll(oppBinds);
        }

        Integer total;
        if (useOppJoin) {
            total = (Integer)Database.countQueryWithBinds(countSoql, oppBinds, AccessLevel.USER_MODE);
        } else {
            total = (Integer)Database.countQuery(countSoql);
        }

        AccountLocationResult result = new AccountLocationResult();
        result.records = new List<AccountLocationDto>();
        result.totalWithGeo = total;
        result.truncated = total > limitSize + offsetSize;

        List<Account> rows = Database.queryWithBinds(dataSoql, binds, AccessLevel.USER_MODE);

        for (Account row : rows) {
            AccountLocationDto loc = new AccountLocationDto();
            loc.accountId = row.Id;
            loc.name = row.Name;
            loc.latitude = row.BillingLatitude;
            loc.longitude = row.BillingLongitude;
            result.records.add(loc);
        }
        return result;
    }

    @AuraEnabled(cacheable=true)
    public static List<LookupEntry> getActiveOwners() {
        List<LookupEntry> entries = new List<LookupEntry>();
        for (User u : [
            SELECT Id, Name
            FROM User
            WHERE IsActive = TRUE AND UserType = 'Standard'
            ORDER BY Name
            LIMIT 200
        ]) {
            LookupEntry entry = new LookupEntry();
            entry.value = u.Id;
            entry.label = u.Name;
            entries.add(entry);
        }
        return entries;
    }

    public class PicklistOption {
        @AuraEnabled
        public String value;
        @AuraEnabled
        public String label;
    }

    @AuraEnabled(cacheable=true)
    public static List<PicklistOption> getOpportunityStageOptions() {
        List<PicklistOption> options = new List<PicklistOption>();
        for (Schema.PicklistEntry pe : Opportunity.StageName.getDescribe().getPicklistValues()) {
            PicklistOption row = new PicklistOption();
            row.value = pe.getValue();
            row.label = pe.getLabel();
            options.add(row);
        }
        options.sort(new PicklistOptionLabelComparator());
        return options;
    }

    private class PicklistOptionLabelComparator implements Comparator<PicklistOption> {
        public Integer compare(PicklistOption a, PicklistOption b) {
            if (a == null && b == null) {
                return 0;
            }
            if (a == null) {
                return -1;
            }
            if (b == null) {
                return 1;
            }
            String la = a.label == null ? '' : a.label;
            String lb = b.label == null ? '' : b.label;
            return la.compareTo(lb);
        }
    }

    public class LookupEntry {
        @AuraEnabled
        public Id value;
        @AuraEnabled
        public String label;
    }

    private static String resolveStageName(String value) {
        if (value == null) {
            return null;
        }
        String trimmed = value.trim();
        return String.isBlank(trimmed) ? null : trimmed;
    }

    private static Date parseDate(String value) {
        if (String.isBlank(value)) {
            return null;
        }
        String trimmed = value.trim();
        if (trimmed.length() >= 10) {
            trimmed = trimmed.substring(0, 10);
        }
        return Date.valueOf(trimmed);
    }

    private static Id parseId(String value) {
        if (String.isBlank(value)) {
            return null;
        }
        String trimmed = value.trim();
        try {
            return (Id)trimmed;
        } catch (Exception ex) {
            return null;
        }
    }

    // Bind map entries must match SOQL binds only; values cannot be null (Database.countQueryWithBinds).
    private static String appendOpportunityFilters(
        Date startDate,
        Date endDate,
        Id ownerId,
        String stage,
        Map<String, Object> binds
    ) {
        String clause = '';
        if (startDate != null) {
            clause += ' AND CloseDate >= :startDate';
            binds.put('startDate', startDate);
        }
        if (endDate != null) {
            clause += ' AND CloseDate <= :endDate';
            binds.put('endDate', endDate);
        }
        if (ownerId != null) {
            clause += ' AND OwnerId = :ownerId';
            binds.put('ownerId', ownerId);
        }
        if (String.isNotBlank(stage)) {
            clause += ' AND StageName = :stage';
            binds.put('stage', stage);
        }
        return clause;
    }

    private static Integer aggregateCount(
        Boolean isClosed,
        Boolean isWon,
        Date startDate,
        Date endDate,
        Id ownerId,
        String stage
    ) {
        Map<String, Object> binds = new Map<String, Object>();
        String soql;
        // Match standard "open" definition: not closed (IsWon is only meaningful when closed).
        if (isClosed == false && isWon == false) {
            soql = 'SELECT COUNT() FROM Opportunity WHERE IsClosed = FALSE';
        } else {
            binds.put('isClosed', isClosed);
            binds.put('isWon', isWon);
            soql = 'SELECT COUNT() FROM Opportunity WHERE IsClosed = :isClosed AND IsWon = :isWon';
        }
        soql += appendOpportunityFilters(startDate, endDate, ownerId, stage, binds);
        return (Integer)Database.countQueryWithBinds(soql, binds, AccessLevel.USER_MODE);
    }

    private static Decimal aggregateSum(
        Boolean isClosed,
        Boolean isWon,
        Date startDate,
        Date endDate,
        Id ownerId,
        String stage
    ) {
        Map<String, Object> binds = new Map<String, Object>();
        String soql;
        if (isClosed == false && isWon == false) {
            soql = 'SELECT SUM(Amount) totalAmt FROM Opportunity WHERE IsClosed = FALSE';
        } else {
            binds.put('isClosed', isClosed);
            binds.put('isWon', isWon);
            soql = 'SELECT SUM(Amount) totalAmt FROM Opportunity WHERE IsClosed = :isClosed AND IsWon = :isWon';
        }
        soql += appendOpportunityFilters(startDate, endDate, ownerId, stage, binds);
        List<AggregateResult> rows = (List<AggregateResult>)Database.queryWithBinds(soql, binds, AccessLevel.USER_MODE);
        if (rows.isEmpty() || rows[0].get('totalAmt') == null) {
            return 0;
        }
        return (Decimal)rows[0].get('totalAmt');
    }

    private static List<StageSlice> aggregateByStage(Date startDate, Date endDate, Id ownerId, String stage) {
        Map<String, Object> binds = new Map<String, Object>();
        String soql =
            'SELECT StageName stage, COUNT(Id) cnt, SUM(Amount) amt FROM Opportunity WHERE IsClosed = FALSE';
        soql += appendOpportunityFilters(startDate, endDate, ownerId, stage, binds);
        soql += ' GROUP BY StageName ORDER BY SUM(Amount) DESC NULLS LAST LIMIT :sliceLimit';
        binds.put('sliceLimit', MAX_AGGREGATE_ROWS);

        List<StageSlice> slices = new List<StageSlice>();
        for (AggregateResult row : (List<AggregateResult>)Database.queryWithBinds(soql, binds, AccessLevel.USER_MODE)) {
            StageSlice slice = new StageSlice();
            slice.stageName = (String)row.get('stage');
            slice.recordCount = (Integer)row.get('cnt');
            slice.totalAmount = row.get('amt') == null ? 0 : (Decimal)row.get('amt');
            slices.add(slice);
        }
        return slices;
    }
}