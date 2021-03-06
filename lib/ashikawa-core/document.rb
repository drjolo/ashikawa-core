require 'ashikawa-core/exceptions/client_error/resource_not_found/document_not_found'

module Ashikawa
  module Core
    # A certain Document within a certain Collection
    class Document
      # The ID of the document (this includes the Collection prefix)
      #
      # @return [String]
      # @api public
      # @example Get the ID for a Document
      #   document = Ashikawa::Core::Document.new(database, raw_document)
      #   document.id # => "my_fancy_collection/2345678"
      attr_reader :id

      # The key of the document (No collection prefix)
      #
      # @return [String]
      # @api public
      # @example Get the key for a Document
      #   document = Ashikawa::Core::Document.new(database, raw_document)
      #   document.key # => "2345678"
      attr_reader :key

      # The current revision of the document
      #
      # @return [String]
      # @api public
      # @example Get the Revision for a Document
      #   document = Ashikawa::Core::Document.new(database, raw_document)
      #   document.revision # => 3456789
      attr_reader :revision

      # Initialize a Document with the database and raw data
      #
      # @param [Database] database
      # @param [Hash] raw_document
      # @api public
      # @example Create a document
      #   document = Ashikawa::Core::Document.new(database, raw_document)
      def initialize(database, raw_document)
        @database = database
        parse_raw_document(raw_document)
      end

      # Raises an exception if the document is not persisted
      #
      # @raise [DocumentNotFoundException]
      # @return nil
      # @api semipublic
      # @example Check if the document is persisted
      #   document = Ashikawa::Core::Document.new(database, raw_document)
      #   document.check_if_persisted!
      def check_if_persisted!
        raise DocumentNotFoundException if @id.nil?
      end

      # Get the value of an attribute of the document
      #
      # @param [String] attribute_name
      # @return [Object] The value of the attribute
      # @api public
      # @example Get the name attribute of a document
      #   document = Ashikawa::Core::Document.new(database, raw_document)
      #   document['name'] #=> 'Lebowski'
      def [](attribute_name)
        @content[attribute_name]
      end

      # Remove the document from the database
      #
      # @return [Hash] parsed JSON response from the server
      # @api public
      # @example Delete a document
      #   document = Ashikawa::Core::Document.new(database, raw_document)
      #   document.delete
      def delete
        check_if_persisted!
        send_request_for_document(:delete => {})
      end

      # Update the value of an attribute (Does not write to database)
      #
      # @param [String] attribute_name
      # @param [Object] value
      # @return [Object] The value
      # @api public
      # @example Change the name attribute of a document
      #   document = Ashikawa::Core::Document.new(database, raw_document)
      #   document['name'] = 'The dude'
      def []=(attribute_name, value)
        check_if_persisted!
        @content[attribute_name] = value
      end

      # Convert the document into a hash
      #
      # @return [Hash]
      # @api public
      # @example Get the hash representation of a document
      #   document = Ashikawa::Core::Document.new(database, raw_document)
      #   document.to_hash #=> { :name => "Lebowski", :occupation => "Not occupied" }
      def to_hash
        @content
      end

      # Save the changes to the database
      #
      # @return [Hash] parsed JSON response from the server
      # @api public
      # @example Save changes to a document
      #   document = Ashikawa::Core::Document.new(database, raw_document)
      #   document['occupation'] = 'Not occupied'
      #   document.save
      def save()
        check_if_persisted!
        send_request_for_document(:put => @content)
      end

      protected

      # Parse information returned from the server
      #
      # @param [Hash] raw_document
      # @return self
      # @api private
      def parse_raw_document(raw_document)
        @id       = raw_document['_id']
        @key      = raw_document['_key']
        @revision = raw_document['_rev']
        @content  = raw_document.delete_if { |key, value| key.start_with?("_") }
        self
      end

      # Send a request for this document with the given opts
      #
      # @param [Hash] opts Options for this request
      # @return [Hash] The parsed response from the server
      # @api private
      def send_request_for_document(opts = {})
        @database.send_request("document/#{@id}", opts)
      end
    end
  end
end
