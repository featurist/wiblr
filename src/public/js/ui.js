((function() {
    var self, trimMiddleOf, sortedPairsIn, Page, contentTypes, Request;
    self = this;
    trimMiddleOf = function(string, length) {
        if (string.length > length) {
            var start, end;
            start = string.substring(0, length / 2);
            end = string.substring(string.length - length / 2, string.length);
            return start + " ... " + end;
        } else {
            return string;
        }
    };
    sortedPairsIn = function(object) {
        var pairs;
        pairs = _.map(object, function(value, name) {
            return {
                name: name,
                value: value
            };
        });
        return _.sortBy(pairs, function(pair) {
            return pair.name;
        });
    };
    ko.bindingHandlers.time = {
        update: function(element, valueAccessor) {
            var self, value, pattern;
            self = this;
            value = ko.utils.unwrapObservable(valueAccessor());
            pattern = "HH:mm:ss";
            return $(element).text(moment(value).format(pattern));
        }
    };
    Page = $class({
        constructor: function() {
            var self;
            self = this;
            self.requests = ko.observableArray();
            return self.selectedRequest = ko.observable();
        },
        addRequest: function(data) {
            var self;
            self = this;
            return self.requests.push(new Request(self, data));
        },
        deselectRequest: function() {
            var self, r;
            self = this;
            r = self.selectedRequest();
            if (r) {
                return r.selected(false);
            }
        }
    });
    contentTypes = {
        txt: /text\/plain/,
        jpg: /jpe?g/,
        png: /png/,
        gif: /gif/,
        html: /html/,
        css: /css/,
        js: /javascript/,
        json: /json/
    };
    Request = $class({
        constructor: function(page, fields) {
            var self, field;
            self = this;
            self.page = page;
            self.responseBody = ko.observable();
            for (var field in fields) {
                (function(field) {
                    self[field] = fields[field];
                })(field);
            }
            self.selected = ko.observable(false);
            self.sortedRequestHeaders = ko.computed(function() {
                return sortedPairsIn(self.requestHeaders);
            });
            self.sortedResponseHeaders = ko.computed(function() {
                return sortedPairsIn(self.responseHeaders);
            });
            self.trimmedPath = ko.computed(function() {
                return trimMiddleOf(self.path, 50);
            });
            self.simplifiedContentType = ko.computed(function() {
                return self.contentType.split(";")[0];
            });
            return self.kind = ko.computed(function() {
                var kind, type;
                kind = "unknown";
                for (var type in contentTypes) {
                    (function(type) {
                        if (self.contentType.match(contentTypes[type])) {
                            kind = type;
                        }
                    })(type);
                }
                return kind;
            });
        },
        select: function() {
            var self;
            self = this;
            self.page.deselectRequest();
            self.page.selectedRequest(self);
            return self.selected(true);
        }
    });
    $(function() {
        var socket;
        window.thePage = new Page;
        ko.applyBindings(window.thePage);
        socket = io.connect();
        return socket.on("capture", function(request) {
            return window.thePage.addRequest(request);
        });
    });
})).call(this);