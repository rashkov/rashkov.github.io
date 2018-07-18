Dear friend,

What is an API?

An API, or "application programming interface", is sort of like a library. It is
a bundle of code, which lives on a dedicated server computer, somewhere out
there on the internet. You can interact with it by sending network packets
containing HTTP (hyper-text transfer protocol) data.

Some examples of HTTP:

// Read email #42342
GET http://yahoo.com/emails/42342

// Creates a new email
POST http://yahoo.com/emails/42342

// Update email #42342
PUT http://yahoo.com/emails/42342

// Deletes email #42342
DELETE http://yahoo.com.com/emails/42342

This is sometimes called "C.R.U.D":
  CREATE - POST
  READ   - GET
  UPDATE - PUT
  DELETE - DELETE

If you open your browser's developer tools (CTRL-SHIFT-I or CMD-SHIFT-I, in
google chrome), and
click on the "Network" tab at the top of the screen, and then load a web page,
you can monitor this HTTP traffic. When you click on an email, you'll see a GET
request for that email. When you hit "SEND" in your email program, you'll see a
POST (to "create" a new email)... At least that's the theory. In practice,
a program like yahoo mail or google mail (gmail) will have their own
conventions, or ways of doing things. Their actual network traffic probably won't
look as clean as the examples that I showed above. But they do all use GET, PUT,
POST, and DELETE. Those are specified by the HTTP protocol. 

Specifications are published by the IETF here: https://tools.ietf.org/html/rfc2616

This paper includes the authore Tim Berners Lee, who is celebrated as the
"Inventor of the Internet". He created the first web browser, and came up with
this HTTP protocol. He wanted to make it easier for scientists to share research
papers with each other. Isn't that amazing?


  GET is specified here: https://tools.ietf.org/html/rfc2068#section-9.3
     The GET method means retrieve whatever information (in the form of an
     entity) is identified by the Request-URI.

In other words, it should retrieve information.

  POST is specified here: https://tools.ietf.org/html/rfc2068#section-9.5
      POST is designed to allow a uniform method to cover the following functions:
       o  Annotation of existing resources;

       o  Posting a message to a bulletin board, newsgroup, mailing list,
          or similar group of articles;

       o  Providing a block of data, such as the result of submitting a
          form, to a data-handling process;

       o  Extending a database through an append operation.
  (Uploading an image, submitting a new blog spot, sending a new email. This
  "creates" a resource.)

In other words, it creates a new resource. A resource is a "thing", and it's up
to the programmer to decide what that "thing" is. It could be a photograph, an
email, a blog post, or even your login information (such as when you sign onto a
website).

  PUT is specified here: https://tools.ietf.org/html/rfc2068#section-9.6

     The PUT method requests that the enclosed entity be stored under the
     supplied Request-URI. If the Request-URI refers to an already
     existing resource, the enclosed entity SHOULD be considered as a
     modified version of the one residing on the origin server. If the
     Request-URI does not point to an existing resource, and that URI is
     capable of being defined as a new resource by the requesting user
     agent, the origin server can create the resource with that URI. If a
     new resource is created, the origin server MUST inform the user agent
     via the 201 (Created) response.  If an existing resource is modified,
     either the 200 (OK) or 204 (No Content) response codes SHOULD be sent
     to indicate successful completion of the request. If the resource
     could not be created or modified with the Request-URI, an appropriate
     error response SHOULD be given that reflects the nature of the
     problem. The recipient of the entity MUST NOT ignore any Content-*
     (e.g. Content-Range) headers that it does not understand or implement
     and MUST return a 501 (Not Implemented) response in such cases.

I hope that helps! Best regards and until next time
