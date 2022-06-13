import Navbar from '../navbar';

interface Props {
    children: React.ReactNode;
}

const BaseLayout: React.FC<Props> = ({ children }) => {
    return (
        <>
            <Navbar />
            <div className="py-16 bg-gray-50 overflow-hidden min-h-screen">
                <div className="max-w-7xl mx-auto space-y-8 px-4 sm:px-6 lg:px-8">
                    {children}
                </div>
            </div>
        </>
    );
};

export default BaseLayout;
