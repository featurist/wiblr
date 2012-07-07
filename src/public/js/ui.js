((function() {
    var self, trimMiddleOf, sortedPairsIn, Page, contentTypes, Request;
    self = this;
    trimMiddleOf = function(string, length) {
        var start, end;
        if (string.length > length) {
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
    ko.bindingHandlers.groupToggle = {
        init: function(element, valueAccessor) {
            var self;
            self = this;
            return $(element).find(".btn").click(function() {
                var self, value;
                self = this;
                value = $(self).val();
                return valueAccessor()(value);
            });
        },
        update: function(element, valueAccessor) {
            var self, value;
            self = this;
            value = ko.utils.unwrapObservable(valueAccessor());
            $(element).find(".btn[value!=" + value + "]").removeClass("active");
            return $(element).find(".btn[value=" + value + "]").addClass("active");
        }
    };
    Page = $class({
        constructor: function() {
            var self;
            self = this;
            self.connectionStatus = ko.observable("connecting");
            self.requests = ko.observableArray();
            self.selectedRequest = ko.observable();
            self.layout = ko.observable("split");
            self.pretty = ko.observable(false);
            $("#load").click(function() {
                return self.reloadHistoricalData();
            });
            return $(".layout.button").click(function(e) {
                return self.change_layout(e);
            });
        },
        change_layout: function(e) {
            var self;
            self = this;
            self.layout($(e.currentTarget).attr("data-layout"));
            return false;
        },
        connected: function() {
            var self;
            self = this;
            return self.connectionStatus("connected");
        },
        disconnected: function() {
            var self;
            self = this;
            return self.connectionStatus("connecting");
        },
        roundToNearestSecond: function(time) {
            var self;
            self = this;
            return time - time % 1e3;
        },
        reloadHistoricalData: function() {
            var self, maxX, minX;
            self = this;
            self.scale = $("#scale").val();
            maxX = self.roundToNearestSecond((new Date).getTime());
            minX = maxX - self.scale * 60 * 1e3;
            return $.get("/exchanges/summary?over=" + self.scale).done(function(exchanges) {
                var gen1_items, gen2_i, exchange;
                self.requests([]);
                gen1_items = exchanges;
                for (gen2_i = 0; gen2_i < gen1_items.length; gen2_i++) {
                    exchange = gen1_items[gen2_i];
                    self.requests.push(new Request(self, exchange));
                }
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
                return self.requests.unshift(new Request(self, data));
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
            self.contentLength(fields.contentLength);
            self.status(fields.status);
            return self.responseHeaders(fields.responseHeaders);
        },
        makeObservable: function(fields) {
            var self;
            self = this;
            self.uuid = fields.uuid;
            self.time = fields.time;
            self.method = fields.method;
            self.protocol = fields.protocol;
            self.host = fields.host;
            self.path = fields.path;
            self.url = fields.url;
            self.requestHeaders = ko.observable(fields.requestHeaders);
            self.contentLength = ko.observable(fields.contentLength);
            self.status = ko.observable(fields.status);
            self.responseHeaders = ko.observable(fields.responseHeaders);
            self.scheme = "http";
            self.selected = ko.observable(false);
            self.over = ko.observable(false);
            self.toggleOver = function() {
                var self;
                self = this;
                return self.over(!self.over());
            };
            self.sortedRequestHeaders = ko.computed(function() {
                return sortedPairsIn(self.requestHeaders());
            });
            self.sortedResponseHeaders = ko.computed(function() {
                return sortedPairsIn(self.responseHeaders());
            });
            self.trimmedPath = ko.computed(function() {
                return trimMiddleOf(self.path || "", 50);
            });
            self.requestContentType = ko.computed(function() {
                var headers;
                headers = self.requestHeaders();
                if (headers) {
                    return headers["content-type"];
                }
            });
            self.responseContentType = ko.computed(function() {
                var headers;
                headers = self.responseHeaders();
                if (headers) {
                    return headers["content-type"];
                }
            });
            self.simplifiedResponseContentType = ko.computed(function() {
                if (self.responseContentType()) {
                    return self.responseContentType().split(";")[0];
                }
            });
            self.statusClasses = "status-" + (self.status() + "")[[ 0 ]] + "xx status-" + self.status();
            self.kind = ko.computed(function() {
                var kind, type;
                kind = "unknown";
                if (!self.status()) {
                    kind = "pending";
                }
                if (self.responseContentType()) {
                    for (type in contentTypes) {
                        (function(type) {
                            if (self.responseContentType().match(contentTypes[type])) {
                                kind = type;
                            }
                        })(type);
                    }
                }
                return kind;
            });
            self.colspan = ko.computed(function() {
                if (self.over()) {
                    return 5;
                } else {
                    return 1;
                }
            });
            self.responseUrl = ko.computed(function() {
                return "/exchanges/" + self.uuid + "/responsebody/" + function() {
                    if (self.page.pretty()) {
                        return "pretty";
                    } else {
                        return "html";
                    }
                }();
            });
            return self.requestHref = ko.computed(function() {
                if (/get/i.test(self.method)) {
                    return self.url;
                }
            });
        },
        select: function() {
            var self, wasSelected, action;
            self = this;
            wasSelected = self.selected();
            self.page.deselectRequest();
            self.page.selectedRequest(self);
            self.selected(true);
            if (self.recentlySelected) {
                clearTimeout(self.clickTimeout);
                action = function() {
                    return self.doubleClick(wasSelected);
                };
            } else {
                action = function() {
                    return self.singleClick(wasSelected);
                };
            }
            self.recentlySelected = true;
            return self.clickTimeout = setTimeout(function() {
                self.recentlySelected = false;
                return action();
            }, 250);
        },
        singleClick: function(wasSelected) {
            var self;
            self = this;
            if (self.page.layout() === "split" && wasSelected) {
                self.page.layout("list");
                return;
            }
            if (self.page.layout() === "detail" && wasSelected) {
                self.page.layout("split");
                return;
            }
            if (self.page.layout() === "list") {
                self.page.layout("split");
                return;
            }
        },
        doubleClick: function(wasSelected) {
            var self;
            self = this;
            if (self.page.layout() === "detail" && wasSelected) {
                return self.page.layout("split");
            } else {
                return self.page.layout("detail");
            }
        }
    });
    $(function() {
        var socket;
        $("html").removeClass("preload");
        window.exchangesReceived = 0;
        window.thePage = new Page;
        ko.applyBindings(window.thePage);
        $(".btn-group").button();
        socket = io.connect();
        socket.on("connect", function() {
            return window.thePage.connected();
        });
        socket.on("disconnect", function() {
            return window.thePage.disconnected();
        });
        return socket.on("exchange", function(request) {
            window.exchangesReceived = window.exchangesReceived + 1;
            return window.thePage.addRequest(request);
        });
    });
})).call(this);