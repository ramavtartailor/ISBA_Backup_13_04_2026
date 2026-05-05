public class CompanyNameFuzzyMatcher {
    
    // Helper class for sorting with Comparable
    public class AccountScore implements Comparable {
        public Account acc { get; set; }
        public Integer score { get; set; }
        
        public AccountScore(Account acc, Integer score) {
            this.acc = acc;
            this.score = score;
        }
        
        // Compare by ascending score (lower = better match)
        public Integer compareTo(Object obj) {
            AccountScore other = (AccountScore) obj;
            return this.score - other.score;
        }
    }
    
    // Common business entity suffixes to remove
    private static Set<String> COMMON_SUFFIXES = new Set<String>{
        'association', 'co', 'company', 'corp', 'corporation', 'dba', 'inc', 'limited',
            'ltd', 'lc', 'llc', 'pllc', 'lp', 'llp', 'lllp', 'pbd', 'the', 'of'
            };
                
                // Clean input: remove special chars, lower case, remove suffixes
                public static String cleanCompanyName(String companyName) {
                    if (String.isBlank(companyName)) return '';
                    String temp = companyName.toLowerCase().replaceAll('[^0-9a-z ]', ' ');
                    temp = temp.replaceAll('\\s+', ' ').trim();
                    List<String> words = temp.split(' ');
                    List<String> filtered = new List<String>();
                    for (String word : words) {
                        if (!COMMON_SUFFIXES.contains(word)) filtered.add(word);
                    }
                    return String.join(filtered, ' ');
                }
    
    // Escape SOQL LIKE meta chars
    public static String escapeSoqlLike(String s) {
        s = s.replace('\\', '\\\\');
        s = s.replace('\'', '\\\'');
        s = s.replace('_', '\\_');
        s = s.replace('%', '\\%');
        return s;
    }
    
    // Levenshtein Distance implementation in Apex
    public static Integer levenshtein(String a, String b) {
        if (a == null) a = '';
        if (b == null) b = '';
        
        Integer n = a.length() + 1;
        Integer m = b.length() + 1;
        
        // Initialize dp as List<List<Integer>>
        List<List<Integer>> dp = new List<List<Integer>>();
        for (Integer i = 0; i < n; i++) {
            List<Integer> row = new List<Integer>();
            for (Integer j = 0; j < m; j++) {
                row.add(0);
            }
            dp.add(row);
        }
        
        // Initialize base cases
        for (Integer i = 0; i < n; i++) dp[i].set(0, i);
        for (Integer j = 0; j < m; j++) dp[0].set(j, j);
        
        // Compute Levenshtein distance
        for (Integer i = 1; i < n; i++) {
            for (Integer j = 1; j < m; j++) {
                Integer cost = (a.substring(i - 1, i) == b.substring(j - 1, j)) ? 0 : 1;
                Integer deletion = dp[i - 1][j] + 1;
                Integer insertion = dp[i][j - 1] + 1;
                Integer substitution = dp[i - 1][j - 1] + cost;
                dp[i].set(j, Math.min(deletion, Math.min(insertion, substitution)));
            }
        }
        
        return dp[n - 1][m - 1];
    }
    
    
    // Main method: Get similar Account names, sorted by similarity (lowest edit distance first)
    public static List<Account> findAccountsByFuzzyName(String inputName, Integer limitCount) {
        String cleanName = cleanCompanyName(inputName);
        System.debug(cleanName);
        String escaped = escapeSoqlLike(cleanName);
        System.debug(escaped);
        List<Account> matches = [
            SELECT Id, Name 
            FROM Account 
            WHERE Name LIKE :('%' + escaped + '%')
            LIMIT :limitCount
        ];
        
        // Score and sort using Levenshtein on the Apex side
        List<AccountScore> scored = new List<AccountScore>();
        for (Account acc : matches) {
            Integer score = levenshtein(cleanName, cleanCompanyName(acc.Name));
            scored.add(new AccountScore(acc, score));
        }
        scored.sort();
        
        // Extract sorted Accounts
        List<Account> sorted = new List<Account>();
        for (AccountScore asObj : scored) {
            sorted.add(asObj.acc);
        }
        return sorted;
    }
}