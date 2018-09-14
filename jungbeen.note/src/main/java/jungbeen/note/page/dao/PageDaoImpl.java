package jungbeen.note.page.dao;

import java.util.List;

import jungbeen.note.page.dao.mapper.PageMapper;
import jungbeen.note.page.domain.Page;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

@Repository
public class PageDaoImpl implements PageDao {
	@Autowired private PageMapper pageMapper;
	
	@Override
	public List<Page> selectPages(int noteId) {
		return pageMapper.selectPages(noteId);
	}
	
	@Override
	public Page selectPage(Page page) {
		return pageMapper.selectPage(page);
	}
	
	@Override
	public int insertPage(Page page) {
		return pageMapper.insertPage(page);
	}
	
	@Override
	public int updatePage(Page page) {
		return pageMapper.updatePage(page);
	}
	
	@Override
	public int deletePage(Page page) {
		return pageMapper.deletePage(page);
	}
}
