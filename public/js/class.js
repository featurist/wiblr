((function() {
    var self;
    self = this;
    window.$class = function(prototype) {
        var self;
        self = this;
        constructor = function() {
            var args, self;
            args = Array.prototype.slice.call(arguments, 0, arguments.length);
            self = this;
            prototype.constructor.apply(self, args);
            return void 0;
        };
        constructor.prototype = prototype;
        return constructor;
    };
    window.$classExtending = function(baseConstructor, prototypeMembers) {
        var self, prototypeConstructor, prototype;
        self = this;
        prototypeConstructor = function() {
            var self, field;
            self = this;
            for (var field in prototypeMembers) {
                (function(field) {
                    if (prototypeMembers.hasOwnProperty(field)) {
                        self[field] = prototypeMembers[field];
                    }
                })(field);
            }
        };
        prototypeConstructor.prototype = baseConstructor.prototype;
        prototype = new prototypeConstructor;
        constructor = function() {
            var args, self;
            args = Array.prototype.slice.call(arguments, 0, arguments.length);
            self = this;
            prototypeMembers.constructor.apply(self, args);
            return void 0;
        };
        constructor.prototype = prototype;
        return constructor;
    };
})).call(this);