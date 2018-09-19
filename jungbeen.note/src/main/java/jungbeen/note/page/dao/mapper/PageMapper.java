package jungbeen.note.page.dao.mapper;

import java.util.List;

import jungbeen.note.page.domain.Page;

public interface PageMapper {
	List<Page> selectPages(int noteId);
	Page selectPage(Page page); //required noteId, idx
	int insertPage(Page page);
	int updatePage(Page page);
	int deletePage(Page page);
	
	int NEXTVAL();
}
