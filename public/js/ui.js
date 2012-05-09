((function() {
    var self;
    self = this;
    $(function() {
        var Page, socket;
        Page = $class({
            constructor: function() {
                var self;
                self = this;
                return self.requests = ko.observableArray();
            },
            addRequest: function(request) {
                var self;
                self = this;
                return self.requests.push(request);
            }
        });
        window.thePage = new Page;
        ko.applyBindings(window.thePage);
        socket = io.connect();
        return socket.on("capture", function(request) {
            return window.thePage.addRequest(request);
        });
    });
})).call(this);