def lambda_handler(event, context):
   message = 'Hello World, I am Praveen {} !'.format(event['key1'])
   return {
       'message' : message
   }

   
