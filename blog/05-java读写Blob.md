### Java代码操作数据库Blob类型数据



#### SQL

```sql
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for test_blob
-- ----------------------------
DROP TABLE IF EXISTS `test_blob`;
CREATE TABLE `test_blob`  (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'id',
  `content` blob NOT NULL COMMENT 'content',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

SET FOREIGN_KEY_CHECKS = 1;

```



#### 一、Java代码存储Blob类型数据

```java
public String saveBlob(@RequestBody @NonNull String blob) throws Exception {
	byte[] bytes = blob.getBytes(StandardCharsets.UTF_8);
	SerialBlob blob1 = new SerialBlob(	
	String sql = "INSERT INTO `test_blob` (id,content) VALUES (null ,?)";
	jdbcTemplate.update(sql, ps -> {
	    ps.setBlob(1, blob1);
	});
	return "success!";
}
```



#### 二、Java代码读取并解析Blob类型数据

```java
public String getBlob(Integer id) {
	String sql = "select * from `test_blob` where id = ?";
	Object[] params = {id};
	List<Object> content = jdbcTemplate.query(sql, new RowMapper<Object>() {
	    @Override
	    public Object mapRow(ResultSet rs, int rowNum) throws SQLException {
	        return rs.getObject("content");
	    }
	}, params);
	byte[] bytes = (byte[]) content.get(0);
	return new String(bytes);
}
```

