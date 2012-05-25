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
            self.selectedRequest = ko.observable();
            self.summaryGraph = Raphael(10, 100, 640, 480);
            return $("#scale").change(function() {
                return self.redrawGraphToScale();
            });
        },
        redrawGraphToScale: function() {
            var self;
            self = this;
            self.scale = $("#scale").val();
            return $.get("/requests/summary?over=" + self.scale * 60).done(function(data) {
                var x, y;
                x = _.map(_.keys(data), function(key) {
                    return key;
                });
                y = _.map(_.keys(data), function(key) {
                    return data[key].requests;
                });
                if (x.length <= 0 || y.length <= 0) {
                    x = [ 0, 1 ];
                    y = [ 0, 0 ];
                }
                if (x.length > 800) {
                    console.log("Invalid graph data", x, y);
                    return;
                }
                self.summaryGraph.clear();
                return self.summaryGraph.linechart(10, 10, 800, 100, x, y, {
                    smooth: true
                });
            });
        },
        addRequest: function(data) {
            var self, openRequest;
            self = this;
            openRequest = _.find(self.requests(), function(request) {
                return request.uuid === data.uuid;
            });
            if (openRequest) {
                return openRequest.update(data);
            } else {
                return self.requests.push(new Request(self, data));
            }
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
            var self;
            self = this;
            self.page = page;
            return self.makeObservable(fields);
        },
        update: function(fields) {
            var self;
            self = this;
            self.contentType(fields.contentType);
            self.status(fields.status);
            return self.responseHeaders(fields.responseHeaders);
        },
        makeObservable: function(fields) {
            var self;
            self = this;
            self.uuid = fields.uuid;
            self.time = fields.time;
            self.method = fields.method;
            self.host = fields.host;
            self.path = fields.path;
            self.requestHeaders = fields.requestHeaders;
            self.contentType = ko.observable(fields.contentType);
            self.status = ko.observable(fields.status);
            self.responseHeaders = ko.observable(fields.responseHeaders);
            self.selected = ko.observable(false);
            self.sortedRequestHeaders = ko.computed(function() {
                return sortedPairsIn(self.requestHeaders);
            });
            self.sortedResponseHeaders = ko.computed(function() {
                return sortedPairsIn(self.responseHeaders());
            });
            self.trimmedPath = ko.computed(function() {
                return trimMiddleOf(self.path, 50);
            });
            self.simplifiedContentType = ko.computed(function() {
                if (self.contentType()) {
                    return self.contentType().split(";")[0];
                }
            });
            return self.kind = ko.computed(function() {
                if (!self.contentType()) {
                    var kind;
                    kind = "pending";
                } else {
                    var type;
                    kind = "unknown";
                    for (var type in contentTypes) {
                        (function(type) {
                            if (self.contentType().match(contentTypes[type])) {
                                kind = type;
                            }
                        })(type);
                    }
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