output "database_endpoints" {
  value = {
    user_db      = aws_db_instance.user_db.endpoint
    chat_db      = aws_db_instance.chat_db.endpoint
    chat_replica = aws_db_instance.chat_db_replica.endpoint
    document_db  = aws_db_instance.document_db.endpoint
    quiz_db      = aws_db_instance.quiz_db.endpoint
  }
}
