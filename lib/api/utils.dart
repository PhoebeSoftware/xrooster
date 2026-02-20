bool validateStatusCode(int? status) => status != null && status >= 200 && status < 300;
