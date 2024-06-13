def lambda_handler(event, context):
   message = 'HelloW {} !'.format(event['key1'])
   return {
       'message' : message
   }

   
