def lambda_handler(event, context):
   message = 'Hello World {} !'.format(event['key1'])
   return {
       'message' : message
   }

   
