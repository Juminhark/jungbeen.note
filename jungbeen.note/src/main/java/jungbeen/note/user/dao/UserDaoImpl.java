package jungbeen.note.user.dao;

import java.util.List;

import jungbeen.note.user.dao.mapper.UserMapper;
import jungbeen.note.user.domain.User;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

@Repository
public class UserDaoImpl implements UserDao{
	@Autowired private UserMapper userMapper;

	public User getUser(String userId){
		return userMapper.getUser(userId);
	}
	
	public List<User> getIds(String userName){
		return userMapper.getIds(userName);
	}
	
	public int addUser(User user){
		return userMapper.addUser(user);
	}
	
	public int updateName(User user){
		return userMapper.updateName(user);
	}
	
	public int updatePw(User user){
		return userMapper.updatePw(user);
	}
	
	public int updateEmail(User user){
		return userMapper.updateEmail(user);
	}
	
	public int delUser(User user){
		return userMapper.delUser(user);
	}
}
