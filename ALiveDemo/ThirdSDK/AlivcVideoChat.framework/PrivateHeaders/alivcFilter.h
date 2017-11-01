#ifndef _ALIVC_FILTER_H_
#define _ALIVC_FILTER_H_

#include <stdint.h>

typedef struct videoFrame
{
    //yuv
    unsigned char*  pData[3];
    uint64_t        pts;
    int             width;
    int             stride;
    int             height;
}videoFrame;

class AlivcFilter
{
public:
    AlivcFilter();
    virtual ~AlivcFilter();
    
public:
    virtual int     init(int width,int stride,int height);
    virtual void    setParam(void* param);
    virtual void*   getParam();
    virtual int     handleFrame(videoFrame* pFrameIn,videoFrame* pFrameOut);
    virtual int     destroy();
    bool            isEnabled();
    void            setEnabled(bool enabled);

    
protected:
    void*   m_param;
    int     m_inited;
    bool    m_enabled;
};


#endif //#_ALIVC_FILTER_H_
