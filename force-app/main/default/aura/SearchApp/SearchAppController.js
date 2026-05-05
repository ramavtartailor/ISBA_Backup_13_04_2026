({
    doInit : function(component, event, helper) {
        var searchQuery = component.get("v.search");

        var payload = {
            componentDef: "forceSearch:search",
            attributes: {
                term: searchQuery,
                scopeMap: {
                    type: "TOP_RESULTS"
                },
                context: {
                    disableSpellCorrection: false,
                    SEARCH_ACTIVITY: {
                        term: searchQuery
                    }
                }
            }
        };

        var encodedString = btoa(JSON.stringify(payload));

        window.location = "/one/one.app#" + encodedString;
    }
});