(function(ctx){

  // Substance.RemoteStore Interface
  // -------

  var RemoteStore = function(options) {
    var that = this;
    this.client = options.client;

    // Create a new document
    // -------

    this.create = function(id, cb) {
      this.client.createDocument(id, cb);
    };

    // Get document by id
    // -------

    this.get = function(id, cb) {
      this.client.getDocument(id, cb);
    };

    // List all allowed documents complete with metadata
    // -------

    // TODO: Currently the hub returns a hash for documents, should be a list!
    this.list = function (cb) {
      this.client.listDocuments(cb);
    };

    // Permanently deletes a document
    // -------

    this.delete = function (id, cb) {
      this.client.deleteDocument(id, cb);
    };

    // Checks if a document exists
    // -------

    this.exists = function (id, cb) {
      this.client.getDocument(id, cb);
    };

    // Retrieves a range of the document's commits
    // -------

    this.commits = function(id, head, stop, cb) {
      this.client.documentCommits(id, head, stop, cb);
    };

    // Stores a sequence of commits for a given document id.
    // -------

    // TODO: update original API so they also take meta and refs
    this.update = function(id, newCommits, meta, refs, cb) {
      this.client.updateDocument(id, newCommits, meta, refs, cb);
    };
  };


  // Exports
  if (typeof exports !== 'undefined') {
    exports.RemoteStore = RemoteStore;
  } else {
    if (!ctx.Substance) ctx.Substance = {};
    ctx.Substance.RemoteStore = RemoteStore;
  }
})(this);
