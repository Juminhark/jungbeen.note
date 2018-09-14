package jungbeen.note.user.service;

import java.util.List;

import jungbeen.note.user.dao.UserDao;
import jungbeen.note.user.dao.UserDaoImpl;
import jungbeen.note.user.domain.User;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class UserServiceImpl implements UserService{
	@Autowired private UserDao userDao;
	
	public UserServiceImpl(){
		this.userDao = new UserDaoImpl();
	}

	@Override
	public User findUser(String userId){
		return userDao.getUser(userId);
	}
	
	@Override
	public List<User> findIds(String userName){
		return userDao.getIds(userName);
	}
	
	@Transactional
	public boolean join(User user){
		return userDao.addUser(user)>0;
	}
	
	@Transactional
	public boolean updateName(User user){	
		return userDao.updateName(user)>0;
	}

	@Transactional
	public boolean updatePw(User user){
		return userDao.updatePw(user)>0;
	}
	
	@Transactional
	public boolean updateEmail(User user){
		return userDao.updateEmail(user)>0;
	}
	
	@Transactional
	public boolean delUser(User user){
		return userDao.delUser(user)>0;  
	}
}
